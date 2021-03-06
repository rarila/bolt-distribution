hy#!/bin/bash

VERSION="1.6-RC2"

export COPYFILE_DISABLE=true

cd bolt-git/
[[ -f 'composer.lock' ]] && rm composer.lock
git checkout master
git pull
git submodule init
git submodule update

# If no parameter is passed to the script package the tagged version
if [[ $1 = "" ]] ; then
    echo Doing checkout of version tagged: v$VERSION
    git checkout -q v$VERSION 
    FILENAME="bolt_$VERSION"
else
    # If the parameter 'master' is passed, we already have it, else a commit ID
    # shall be checked out
    if [[ $1 != "master" ]] ; then
        git checkout $1
    fi
    COD=$(git log -1 --date=short --format=%cd)
    GID=$(git log -1 --format=%h)
    FILENAME="bolt_git_$COD_$GID"
fi

php composer.phar self-update
php composer.phar update --no-dev
cd ..

rm -rf bolt
cp -rf bolt-git bolt

rm -rf files/*

find bolt -name ".git*" | xargs rm -rf
find bolt -type d -name "[tT]ests" | xargs rm -rf
rm -rf bolt/vendor/psr/log/Psr/Log/Test bolt/vendor/symfony/form/Symfony/Component/Form/Test bolt/vendor/twig/twig/lib/Twig/Test
rm -rf bolt/vendor/twig/twig/test bolt/vendor/swiftmailer/swiftmailer/test-suite
rm -rf bolt/composer.* bolt/vendor/symfony/locale/Symfony/Component/Locale/Resources/data bolt/.gitignore bolt/app/database/.gitignore
rm -rf bolt/app/view/img/debug-nipple-src.png bolt/app/view/img/*.pxm
rm -rf bolt/vendor/swiftmailer/swiftmailer/doc bolt/vendor/swiftmailer/swiftmailer/notes
rm -rf bolt/theme/default bolt/theme/base-2013/to_be_deleted
rm -rf bolt/.scrutinizer.yml bolt/.travis.yml bolt/codeception.yml bolt/run-functional-tests

# remove ._ files..
[[ -f "/usr/sbin/dot_clean" ]] && dot_clean .

# copy the default config files.
[[ -d "./files" ]] || mkdir ./files/
cp bolt/app/config/config.yml.dist ./files/config.yml
cp bolt/app/config/contenttypes.yml.dist ./files/contenttypes.yml
cp bolt/app/config/menu.yml.dist ./files/menu.yml
cp bolt/app/config/routing.yml.dist ./files/routing.yml
cp bolt/app/config/taxonomy.yml.dist ./files/taxonomy.yml
cp bolt/.htaccess ./files/default.htaccess

# setting the correct filerights
find bolt -type d -exec chmod 755 {} \;
find bolt -type f -exec chmod 644 {} \;
chmod -R 777 bolt/files bolt/app/cache bolt/app/config bolt/app/database bolt/theme

# until Profiler gets tagged. See https://github.com/silexphp/Silex-WebProfiler/pull/31 
patch -p1 < patch/WebProfilerServiceProvider.patch

# URandom in RandomLib. See https://github.com/ircmaxell/RandomLib/pull/16
# patch -p1 < patch/URandom.patch

# Add .htaccess file to vendor/
cp extras/.htaccess bolt/vendor/.htaccess

# Make the archives..
cd bolt
tar -czf ../$FILENAME.tgz * .htaccess
zip -rq ../$FILENAME.zip * .htaccess
cd ..

# Only create 'latest' archives for version releases
if [[ $1 = "" ]] ; then
    cp $FILENAME.tgz ./files/bolt_latest.tgz
    cp $FILENAME.zip ./files/bolt_latest.zip
fi
mv $FILENAME.tgz ./files/
mv $FILENAME.zip ./files/

echo "\nAll done!\n"

# scp files/* bolt@bolt.cm:/home/bolt/public_html/distribution/

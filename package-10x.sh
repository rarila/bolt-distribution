#!/bin/sh

FILENAME="bolt_1.0.5"
export COPYFILE_DISABLE=true

cd bolt-git/
rm composer.lock
git checkout 1.0.x
git pull
php composer.phar self-update
php composer.phar update --no-dev
cd ..

rm -rf bolt
cp -rf bolt-git bolt

rm -rf files/*

find bolt/vendor -name ".git" | xargs rm -rf
find bolt/vendor -name "tests" | xargs rm -rf
find bolt/vendor -name "Tests" | xargs rm -rf
rm -rf bolt/.git bolt/composer.* bolt/vendor/symfony/locale/Symfony/Component/Locale/Resources/data bolt/.gitignore
rm -rf bolt/app/view/img/debug-nipple-src.png bolt/app/view/img/*.pxm
rm -rf bolt/app/view/lib/codemirror/codemirror.js
rm -rf bolt/app/classes/htmLawed/htmLawed_* bolt/app/classes/htmLawed/htmLawedTest.php
rm -rf bolt/vendor/swiftmailer/swiftmailer/doc bolt/vendor/swiftmailer/swiftmailer/notes bolt/vendor/swiftmailer/swiftmailer/test-suite
rm -rf bolt/theme/default bolt/theme/base-2013/to_be_deleted

# remove ._ files..
dot_clean .

# copy the default config files.
cp bolt/app/config/config.yml.dist files/config.yml
cp bolt/app/config/contenttypes.yml.dist files/contenttypes.yml
cp bolt/app/config/menu.yml.dist files/menu.yml
cp bolt/app/config/taxonomy.yml.dist files/taxonomy.yml
cp bolt/.htaccess files/default.htaccess

# setting the correct filerights
find bolt -type d -exec chmod 755 {} \;
find bolt -type f -exec chmod 644 {} \;
chmod -R 777 bolt/files bolt/app/cache bolt/app/config bolt/app/database bolt/theme

# until DBAL is fixed (see: https://github.com/doctrine/dbal/pull/226 )
# cp overrides/SqliteSchemaManager.php bolt/vendor/doctrine/dbal/lib/Doctrine/DBAL/Schema/SqliteSchemaManager.php

# Make the archives..
cd bolt
tar -czf ../$FILENAME.tgz * .htaccess
zip -rq ../$FILENAME.zip * .htaccess
cd ..
cp $FILENAME.tgz ./files/bolt_latest.tgz
mv $FILENAME.tgz ./files/
cp $FILENAME.zip ./files/bolt_latest.zip
mv $FILENAME.zip ./files/

echo "\nAll done!\n"

# scp files/* bolt@128.140.220.72:/home/bolt/public_html/distribution/

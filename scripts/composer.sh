#!/usr/bin/env bash

# Test if PHP is installed
php -v > /dev/null 2>&1
PHP_IS_INSTALLED=$?

if [[ $PHP_IS_INSTALLED -ne 0 ]]; then
  echo "!!! PHP is not installed. Check the Vagrant file."; exit
fi

# Test if Composer is installed
composer -v > /dev/null 2>&1
COMPOSER_IS_INSTALLED=$?

# Contains all arguments that are passed
COMPOSER_PACKAGES=($@)

# True, if composer is not installed
if [[ $COMPOSER_IS_INSTALLED -ne 0 ]]; then
    echo ">>> Installing Composer"
    # Install Composer
    curl -sS https://getcomposer.org/installer | php
    sudo mv composer.phar /usr/local/bin/composer
else
    echo ">>> Updating Composer"
    sudo composer self-update
fi

# Install Global Composer Packages if any are given
if [[ ! -z $COMPOSER_PACKAGES ]]; then

    echo ">>> Installing Global Composer Packages:"
    echo "    " $@
    composer global require $@

    # Add Composer's Global Bin to ~/.profile path
    if [[ -f "/home/vagrant/.profile" ]]; then
        if ! grep -qsc 'COMPOSER_HOME=' /home/vagrant/.profile; then
            # Ensure COMPOSER_HOME variable is set. This isn't set by Composer automatically
            printf "\n\nCOMPOSER_HOME=\"/home/vagrant/.composer\"" >> /home/vagrant/.profile
            # Add composer home vendor bin dir to PATH to run globally installed executables
            printf "\n# Add Composer Global Bin to PATH\n%s" 'export PATH=$PATH:$COMPOSER_HOME/vendor/bin' >> /home/vagrant/.profile

            # Source the .profile to pick up changes
            . /home/vagrant/.profile
        fi
    fi
fi

# Recipes for Fresh Advance organization

Recipes for installing development versions of our modules, easy running of the tests and making pull requests :)

## Prerequirements

1. PERL is required to be available on the system! Try if you have one installed with ``perl -v```
2. Check if other docker projects are stopped! If you have something running, ports may conflict and
   nothing will work as intended, just take a minute and stop everything before running this!
3. You should have docker and docker-compose installed on your machine.
4. Its recommended to use Linux, but Linux subsystem on Windows might fit as well (may hit more problems)
5. The ``127.0.0.1 localhost.local`` should be added to /etc/hosts

## Installation instructions:

1. Clone the SDK, in this case it will be cloned to ``MyProject`` directory:
```
echo MyProject && git clone https://github.com/Fresh-Advance/development $_ && cd $_
```

2. Clone recipes
```
git clone https://github.com/Fresh-Advance/development-recipes recipes/fresh-advance
```

3. And last - run the desired recipe, for example:
```
./recipes/fresh-advance/module-invoice/b-7.0.x-twig.sh
```
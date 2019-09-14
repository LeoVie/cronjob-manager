<?php

require __DIR__ . '/../vendor/autoload.php';

use LeoVie\CronjobManager\CronjobManagerCommand;
use Symfony\Component\Console\Application;

$application = new Application();

$application->add(new CronjobManagerCommand());

$application->run();
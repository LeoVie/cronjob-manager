<?php

namespace LeoVie\CronjobManager;

use LeoVie\CronjobManager\Bash\BashExecutor;
use LeoVie\CronjobManager\Cronjob\CronjobReader;
use LeoVie\CronjobManager\Cronjob\CronjobValidator;
use LeoVie\CronjobManager\Cronjob\CronjobWriter;
use LeoVie\CronjobManager\Util\StringUtil;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Input\InputOption;
use Symfony\Component\Console\Output\OutputInterface;

class CronjobManagerCommand extends Command
{
    protected static $defaultName = 'cronjob-manager';

    protected function configure()
    {
        $this->addArgument('mode', InputOption::VALUE_REQUIRED);
        $this->addArgument('cronjob', InputOption::VALUE_REQUIRED);
    }

    protected function execute(InputInterface $input, OutputInterface $output)
    {
        $bashExecutor = new BashExecutor();
        $stringUtil = new StringUtil();
        $cronjobReader = new CronjobReader($bashExecutor, $stringUtil);
        $cronjobValidator = new CronjobValidator($output);
        $cronjobWriter = new CronjobWriter($bashExecutor, $cronjobReader, $cronjobValidator, $output);

        $mode = $input->getArgument('mode');
        $cronjob = $input->getArgument('cronjob');

        if ($mode === 'add') {
            $cronjobWriter->addCronjobIfNotExists($cronjob);
        } elseif ($mode === 'remove') {
            $cronjobWriter->removeCronjob($cronjob);
        }
    }
}
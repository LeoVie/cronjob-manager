<?php

namespace LeoVie\CronjobManager\Cronjob;

use LeoVie\CronjobManager\Bash\BashExecutor;
use Symfony\Component\Console\Output\OutputInterface;

class CronjobWriter
{
    /** @var BashExecutor */
    private $bashExecutor;

    /** @var CronjobReader */
    private $cronjobReader;

    /** @var CronjobValidator */
    private $cronjobValidator;

    /** @var OutputInterface */
    private $output;

    public function __construct(BashExecutor $bashExecutor, CronjobReader $cronjobReader, CronjobValidator $cronjobValidator, OutputInterface $output)
    {
        $this->bashExecutor = $bashExecutor;
        $this->cronjobReader = $cronjobReader;
        $this->cronjobValidator = $cronjobValidator;
        $this->output = $output;
    }

    public function addCronjobIfNotExists(string $cronjob): void
    {
        if ($this->cronjobReader->cronjobExists($cronjob)) {
            $this->output->writeln("Cronjob '$cronjob' already exists.");
            return;
        }
        if (!$this->cronjobValidator->cronjobFormatIsValid($cronjob)) {
            return;
        }
        $this->addCronjob($cronjob);
    }

    private function addCronjob(string $cronjob): void
    {
        $this->output->writeln("Adding cronjob '$cronjob' to crontab.");
        $this->bashExecutor->execute("crontab -l | { cat; echo \"$cronjob\"; } | crontab -");
    }

    public function removeCronjob(string $cronjob): void
    {
        $this->output->writeln("Removing cronjob '$cronjob' from crontab.");
        $crontab = $this->cronjobReader->readCrontab();
        $newCrontab = str_replace($cronjob . "\n", '', $crontab);
        $this->bashExecutor->execute("echo \"$newCrontab\" | crontab -");
    }
}
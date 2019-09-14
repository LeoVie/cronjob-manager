<?php

namespace LeoVie\CronjobManager\Cronjob;

use LeoVie\CronjobManager\Bash\BashExecutor;
use LeoVie\CronjobManager\Util\StringUtil;

class CronjobReader
{
    /** @var BashExecutor */
    private $bashExecutor;

    /** @var StringUtil */
    private $stringUtil;

    public function __construct(BashExecutor $bashExecutor, StringUtil $stringUtil)
    {
        $this->bashExecutor = $bashExecutor;
        $this->stringUtil = $stringUtil;
    }

    public function cronjobExists(string $cronjob): bool
    {
        $crontab = $this->readCrontab();
        return ($this->stringUtil->stringContains($cronjob, $crontab));
    }

    public function readCrontab(): string
    {
        return $this->bashExecutor->execute('crontab -l');
    }
}
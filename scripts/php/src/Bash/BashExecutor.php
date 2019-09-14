<?php

namespace LeoVie\CronjobManager\Bash;

class BashExecutor
{
    public function execute(string $command): ?string
    {
        return shell_exec($command);
    }
}
<?php

namespace LeoVie\CronjobManager\Cronjob;

use Symfony\Component\Console\Output\OutputInterface;

class CronjobValidator
{
    private const SPECIAL_KEYWORD_PATTERN = '%^@(reboot|daily|midnight|hourly|weekly|monthly|annually|yearly).+%m';
    private const MINUTE_PATTERN = '%^(\\*|\/?0?([0-9]|[1-4][0-9]|5[0-9]))$%m';
    private const HOUR_PATTERN = '%^(\\*|\/?0*([0-9]|1[0-9]|2[0-3]))$%m';
    private const DAY_PATTERN = '%^(\\*|\/?0*([1-9]|[12][0-9]|3[01]))$%m';
    private const MONTH_PATTERN = '%^(\\*|\/?0*([1-9]|1[0-2]))$%m';
    private const WEEKDAY_PATTERN = '%^(\\*|\/?0*([0-7]))$%m';

    /** @var OutputInterface */
    private $output;

    public function __construct(OutputInterface $output)
    {
        $this->output = $output;
    }

    public function cronjobFormatIsValid(string $cronjob): bool
    {
        if (preg_match(self::SPECIAL_KEYWORD_PATTERN, $cronjob)) {
            return true;
        }

        $partsPatterns = [
            self::MINUTE_PATTERN,
            self::HOUR_PATTERN,
            self::DAY_PATTERN,
            self::MONTH_PATTERN,
            self::WEEKDAY_PATTERN,
        ];
        $parts = explode(' ', $cronjob);
        foreach ($partsPatterns as $i => $pattern) {
            if (!(key_exists($i, $parts))) {
                $this->output->writeln("Cronjob '$cronjob' is invalid (too few time items).");
                return false;
            }
            $part = $parts[$i];
            if (!preg_match($pattern, $part)) {
                $this->output->writeln("Cronjob '$cronjob' is invalid (at position $i ('$part')).");
                return false;
            }
        }

        return true;
    }
}
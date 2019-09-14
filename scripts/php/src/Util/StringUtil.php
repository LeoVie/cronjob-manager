<?php

namespace LeoVie\CronjobManager\Util;

class StringUtil
{
    public function stringContains(string $needle, string $haystack): bool
    {
        return (strpos($haystack, $needle) !== false);
    }
}
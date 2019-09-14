<?php

namespace LeoVie\CronjobManager\Unittest\Bash;

use LeoVie\CronjobManager\Cronjob\CronjobValidator;
use PHPUnit\Framework\TestCase;
use Symfony\Component\Console\Output\OutputInterface;

class CronjobValidatorTest extends TestCase
{
    /** @var CronjobValidator */
    private $cronjobValidator;

    public function setUp(): void
    {
        $output = $this->createMock(OutputInterface::class);
        $this->cronjobValidator = new CronjobValidator($output);
    }

    /** @dataProvider cronjobFormatIsValid_provider */
    public function test_cronjobFormatIsValid_returnsExpected(string $cronjob, bool $expected): void
    {
        $actual = $this->cronjobValidator->cronjobFormatIsValid($cronjob);

        self::assertEquals($expected, $actual);
    }

    public function cronjobFormatIsValid_provider(): array
    {
        return [
            ['@daily curl http://localhost', true],
            ['* * * * * curl http://localhost', true],
            ['/15 * * * * curl http://localhost', true],
            ['/15 * * * 7 curl http://localhost', true],
            ['* * * * curl http://localhost', false],
            ['60 * * * * curl http://localhost', false],
            ['* 24 * * * curl http://localhost', false],
            ['* * 32 * * curl http://localhost', false],
            ['* * * 13 * curl http://localhost', false],
            ['* * * * 8 curl http://localhost', false],
        ];
    }
}
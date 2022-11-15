<?php
/**
 * This file is part of Moodle - http:moodle.org/
 *
 * Moodle is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Moodle is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Moodle.  If not, see <http:www.gnu.org/licenses/>.
 */

/**
 * Behat for ace inline filter
 *
 * @package    filter_ace_inline
 * @copyright  2022 Michelle Hsieh, Richard Lobb, University of Canterbury
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */

use Behat\Mink\Exception\ExpectationException as ExpectationException;

class behat_ace_inline extends behat_base {
    
    /**
     * Enables the ace inline functionality globally for testing purposes.
     * 
     * @Given /^I enable ace inline filter/
     */
    public function i_enable_ace_inline() {
        filter_set_global_state('ace_inline', TEXTFILTER_ON, 0);
    }
    
    /**
     * Checks if the programming language is correct, else throws an
     * expectation error with message.
     * 
     * @Given the programming language is :langString
     * @throws ExpectationException The error message.
     * @param string $langString The expected language string.
     */
    public function program_set_to($langString) {
        
        //Assume if python, is default as per settings.
        if (!preg_match("/python/i", $langString)) {
            $xpath = "//pre[@data-lang='$langString']";
        }
        else {
            $xpath = "//pre";
        }
        $error = "Language is not set as $langString";
        $driver = $this->getSession()->getDriver();
        if (!$driver->find($xpath)) {
            throw new ExpectationException($error, $this->getSession());
        }
        
    }
    
    /**
     * Checks if expected word has syntax highlighting
     * 
     * @Then I should see :typeString highlighting on :textString  
     * @throws ExpectationException The error message.
     * @param string $typeString The type of highlighting expected
     * @param string $textString The expected keyword as a string.
     */
    public function i_should_see_highlighting($typeString, $textString) {
        
        //Parse the typeString.
        $acetype = $this->parse_type_string($typeString);

        //Check if there is a <span> containing the expected text of that class-type.
        $xpath = "//span[@class='$acetype' and contains(text(), $textString)]";
        $error = "'{$textString}' is not found/formatted as an $acetype";
        $driver = $this->getSession()->getDriver();
        if (!$driver->find($xpath)) {
            if ($acetype == 'error') {
                $error = "'{$typeString}' is not a valid type";
            }
            throw new ExpectationException($error, $this->getSession());
        }
    }
    
    /**
     * Parses a string input and returns the corresponding acetype identifier
     * for highlight-checking purposes.
     * 
     * @param string $input The string to be parsed.
     * @return string The corresponding acetype identifier.
     */
    private function parse_type_string($input) {
        
        //Handle some basic identifiers; enough to identify a language
        switch ($input) {
            case 'identifier':
                $acetype = 'ace_identifier';
                break;
            case 'keyword':
                $acetype = 'ace_keyword';
                break;
            case 'string':
                $acetype = 'ace_string';
                break;
            case 'include':
                $acetype = 'ace_constant ace_other';
                break;
            case 'constant':
                $acetype = 'ace_constant ace_language';
                break;
            case 'function':
                $acetype = 'ace_support ace_function';
                break;
            default:
                $acetype = 'error';
        }
        return ($acetype);
    }
    
}
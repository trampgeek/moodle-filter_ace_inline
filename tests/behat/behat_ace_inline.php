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
     * @Given /^I have enabled ace inline filter/
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
     * Checks if expected word has syntax highlighting. Takes in the 
     * type expected and the text expected and searches for the text
     * within a <span> container of the appropriate type.
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
        //Needs starts-with as C's function tag is particular and boolean flags.
        $xpath = "//span[starts-with(@class, '$acetype')and contains(text(), $textString)]";
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
     * for highlight-checking purposes. Identifier is just generic-type
     * span class.
     * 
     * @param string $input The string to be parsed.
     * @return string The corresponding acetype identifier.
     */
    private function parse_type_string($input) {
        
        //A array map of keywords to identifiers.
        $array = [
            "identifier" => "ace_identifier",
            "keyword" => "ace_keyword",
            "string" => "ace_string",
            "include" => "ace_constant ace_other",
            "constant" => "ace_constant ace_language",
            "function" => "ace_support ace_function",
            "sqltype" => "ace_storage ace_type"
        ];
        
        if (isset($array[$input])) {
            $acetype = $array[$input];
        }
        else {
            $acetype = "error";
        }
        
        return ($acetype);
    }
    
}
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
use Facebook\WebDriver\Exception\NoSuchAlertException as NoSuchAlertException;


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
        $xpath = "//span[starts-with(@class, '$acetype') and contains(text(), $textString)]";
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
     * Checks if the starting line is the correct line to start from. Searches
     * the text for the correct active line and gets the number. Assumes ace starts
     * from specified line and line++ per line.
     * 
     * @Then I should see lines starting at :number
     * @param string $number The number expected to be found at the start.
     * @throws ExpectationException The error message.
     */
    public function i_see_lines_starting_at($number) {
        
        //Changes the number to a quoted number for exact number.
        $quotedNumber = "\"{$number}\"";
        
        //Checks to see if the first line starts with the right number
        $xpath = "//div[contains(@class, 'ace_gutter-active-line')and text()=$quotedNumber]";
        $driver = $this->getSession()->getDriver();
        $error = "Code does not start at line {$quotedNumber}";
        if (!$driver->find($xpath)) {
            throw new ExpectationException($error, $this->getSession());
        }
    }
    
    /**
     * Checks if the font-size is as specified. Takes in a font-size in 
     * format "11pt" etc. and checks if the style contains specified font-size.
     * 
     * @Then I should see font sized :fontSize
     * @param string $fontSize The size on the font in format "11pt" etc.
     * @throws ExpectationException The error message.
     */
    public function i_see_font_size($fontSize) {
      
        //Turn the font size into an appropriate string to search in style.
        $fontString = "'{$fontSize};'";
        
        $xpath = "//div[starts-with(@class, ' ace_editor') and contains(@style, $fontString)]";
        $driver = $this->getSession()->getDriver();
        $error = "Font size is not {$fontSize}";
        if (!$driver->find($xpath)) {
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
    
    /**
     * Sets the webserver sandbox to enabled for testing purposes.
     * 
     * @Given /^the webserver sandbox is enabled/
     */
    public function the_sandbox_is_enabled() {
        
        set_config('wsenabled', 1, 'qtype_coderunner');
    }
    
    /**
     * Presses a named button. Checks if there is an error,
     * 
     * @Then there is an alert of :error when I press :button
     * @param string The expected error message when alerted
     * @param string The name of the alert button.
     */
    public function there_is_an_alert_when_I_click($errorText, $button) {
        
        // Gets the item of the button.
        $xpath = "//button[@type='button' and text()='$button']";
        $session = $this->getSession();
        $item = $session->getSelectorsHandler()->selectorToXpath('xpath', $xpath);
        $element = $session->getPage()->find('xpath', $item);
        
        //Makes sure there is an element before continuing.
        if ($element) {
            $element->click();
        } else {
            throw new ExpectationException("No button '{$button}'", $this->getSession());
        }
        try {
            // Gets you to wait for the pending JS alert by sleeping. 
            sleep(1);
            // Gets the alert and its text.
            $alert = $this->getSession()->getDriver()->getWebDriver()->switchTo()->alert();
            $alertText = $alert->getText();
        } catch (NoSuchAlertException $ex) {
            throw new ExpectationException("No alert was triggered appropriately", $this->getSession());
        }
        
        // Throws an error if expected error text doesn't match alert.
        if (!str_contains($alertText, $errorText)) {
            throw new ExpectationException("Wrong alert; alert given: {$alertText}", $this->getSession());
        } else {
            // To stop the Behat tests from throwing their own errors.
            $alert->accept();
        }
    }
    
 
}
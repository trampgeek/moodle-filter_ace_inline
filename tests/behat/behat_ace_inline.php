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
     * Checks if expected keyword has syntax highlighting
     * 
     * @Then /^I should see syntax highlighting on "(?P<expected>(?:[^"]|\\")*)"$/ 
     * @throws ExpectedException The error message.
     * @param string $expected The expected keyword as a string.
     */
    public function i_should_see_syntax($expected) {
        $xpath = "//span[@class='ace_keyword' and contains(text(), $expected)]";
        $error = "'{$expected}' is not formatted as a keyword";
        $driver = $this->getSession()->getDriver();
        if (!$driver->find($xpath)) {
            throw new ExpectationException($error, $this->getSession());
        }
    }
    

}

<?php
// This file is part of Moodle - http://moodle.org/
//
// Moodle is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Moodle is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Moodle.  If not, see <http://www.gnu.org/licenses/>.

/**
 * Simple encryption/decryption of question number
 *
 * Version details
 *
 * @package    filter
 * @subpackage simplequestion
 * @copyright  Muhammad Ali: https://stackoverflow.com/users/1418637/muhammad-ali
 * @license    https://creativecommons.org/licenses/by-sa/3.0/
 *
 * Modifed by Richard Jones, https://richardnz.net
 *
 * https://stackoverflow.com/questions/24350891/how-to-encrypt-decrypt-an-integer-in-php 
 *
 */

namespace filter_simplequestion\utility;

class tools  {

  // Encrypt and decrypt an integer using a simple key
  // of alphabetical characters.
  // The encoded number must be alphabetical since it
  // is going to be used in a css id.
  // It also has to begin with a letter for some browsers

   public static function encrypt($string, $key) {
    $result = '';
    for($i=0; $i<strlen($string); $i++) {
      $char = substr($string, $i, 1);
      $keychar = substr($key, ($i % strlen($key))-1, 1);
      $char = chr(ord($char)+ord($keychar));
      $result.=$char;
    }
    $result = base64_encode($result);
    $r1 = str_replace('=', '_', $result);
    $r2 = str_replace('+', '__', $r1);
    $r3 = str_replace('/', '-', $r2);    
    return substr($key, 0, 1) . $r3;
  }

  public static function decrypt($string, $key) {
    $result = '';
    $newstring = substr($string, 1, strlen($string) - 1);
    $s1 = str_replace('_', '=', $newstring);
    $s2 = str_replace('__', '+', $s1);
    $s3 = str_replace('-', '/', $s2);    
    $s4 = base64_decode($s3);

    for($i=0; $i<strlen($s4); $i++) {
      $char = substr($s4, $i, 1);
      $keychar = substr($key, ($i % strlen($key))-1, 1);
      $char = chr(ord($char)-ord($keychar));
      $result.=$char;
    }
    return $result;
  }

}
<?php

$nonflash_patterns = array("/android/i",
			   "/iphone/i",
			   "/ipad/i");

$ua = $_SERVER['HTTP_USER_AGENT'];

$have_flash = 1;

for ($i=0; $i<count($nonflash_patterns); ++$i) {
  if (preg_match($nonflash_patterns[$i], $ua)) {
    $have_flash = 0;
    break;
  }
}

if ($have_flash) {
  include "flash-dashboard.html";
} else {
  include "nonflash-dashboard.html";
}

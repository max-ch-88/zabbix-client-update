<?php
$dir = exec('pwd');
$cmd = 'sh '.$dir.'/.zbx_cfg_md5.sh '.$dir.'/'.$_POST['hostname'];
#$cmd = 'sh '.$dir.'/.zbx_cfg_md5.sh '.$dir.'/rhcsa1.rhce.local';
$output = shell_exec($cmd);
echo $output;
?>

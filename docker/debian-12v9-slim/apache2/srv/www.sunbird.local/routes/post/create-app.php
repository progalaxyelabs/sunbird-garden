<?php

$app_name = strtolower(trim($_POST['app-name'] ?? ''));
// $app_name = preg_replace('/\s/g', ' ', $app_name);
if (preg_match('/[a-z0-9]{3,30}/', $app_name, $matches)) {
    $result = exec("/srv/www.sunbird.local/cli/create-app.sh $app_name 2>&1", $output, $result_code);
    $output[] = PHP_EOL;
    log_cli(print_r($output, true));
    view('app-created.php', [
        'app_url' => "/apps/$app_name",
        'log' => print_r([
            'result' => $result,
            'output' =>  $output,
            'result_code' => $result_code
        ], true)
    ]);
} else {
    view('create-app.php', [
        'app_name' => $app_name,
        'error_message' => 'app name must be alpha-numeric only. 
            allowed name length is 3 to 30 characters'
    ]);
}

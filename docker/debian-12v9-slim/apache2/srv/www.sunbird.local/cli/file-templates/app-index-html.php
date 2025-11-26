<?php
$app_name = ucfirst($argv[1] ?? 'newapp')

?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?= $app_name ?></title>
</head>
<body>
    <?= $app_name ?> works!
</body>
</html>
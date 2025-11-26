<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sunbird<?= $pagename ?? '' ?></title>
</head>

<body>
    <?php include ($viewname ?? '404.php') ?>
    <section>
        <?php
        echo "Requested URI is " . $_SERVER['REQUEST_URI'];
        ?>
    </section>
</body>

</html>
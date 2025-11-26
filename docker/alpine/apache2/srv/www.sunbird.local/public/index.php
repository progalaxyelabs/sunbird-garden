<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sunbird</title>
</head>

<body>
    <h1>Hi, </h1>
    <section>
        <h2>Your Apps</h2>
        <div class="apps-list">
            <a href="/app1">App 1</a>
            <a href="/app2">App 2</a>
            <a href="/app3">App 3</a>
        </div>
    </section>
    <section>
        <?php
            echo "Requested URI is " . $_SERVER['REQUEST_URI'];
        ?>
    </section>
</body>

</html>
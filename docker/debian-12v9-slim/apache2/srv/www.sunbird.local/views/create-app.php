<form method="post">
    <div>
        <label for="app-name">App Name</label>
        <input id="app-name" name="app-name" value="<?= isset($app_name) ? $app_name : 'wh' ?>" />
    </div>
    <!-- <div>
        <label for="app-type-static">App Type</label>
        <input type="radio" id="app-type-static" name="app-type" />
    </div>
    <div>
        <label for="app-type-static">App Type</label>
        <input type="radio" id="app-type-static" name="app-type" />
    </div>
    <div>
        <label for="app-type-static">App Type</label>
        <input type="radio" id="app-type-static" name="app-type" />
    </div> -->
    <button type="submit" name="submit">Create</button>
    <?php if(isset($error_message)) : ?>
        <div>
            <?= $error_message ?>
        </div>    
    <?php endif; ?>
</form>
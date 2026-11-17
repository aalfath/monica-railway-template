<?php
// Creates Monica's first account from MONICA_ADMIN_EMAIL and MONICA_ADMIN_PASSWORD
// when the database has no account yet. Does nothing once an account exists, so
// later password changes made in Monica stay as they are.

require '/var/www/html/vendor/autoload.php';
$app = require '/var/www/html/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use App\Helpers\InstanceHelper;
use App\Models\Account\Account;

$out = fopen('php://stderr', 'w');

if (InstanceHelper::hasAtLeastOneAccount()) {
    fwrite($out, "railway-owner: an account exists, nothing to do.\n");
    exit(0);
}

$email = trim((string) getenv('MONICA_ADMIN_EMAIL'));
$password = (string) getenv('MONICA_ADMIN_PASSWORD');

if ($email === '' || ! filter_var($email, FILTER_VALIDATE_EMAIL)) {
    fwrite($out, "railway-owner: MONICA_ADMIN_EMAIL must be a valid email address.\n");
    exit(1);
}
if (strlen($password) < 12) {
    fwrite($out, "railway-owner: MONICA_ADMIN_PASSWORD must be at least 12 characters.\n");
    exit(1);
}

$account = Account::createDefault('Monica', 'Owner', $email, $password);
$user = $account->users()->first();
$user->markEmailAsVerified();
$user->admin = true;
$user->save();

fwrite($out, "railway-owner: created the first account for {$email}.\n");

$ErrorActionPreference = "Stop"

$modules = @(
    @{ Name = "mod-playerbots";                Repo = "https://github.com/mod-playerbots/mod-playerbots.git";                Branch = "master" },
    @{ Name = "mod-ah-bot";                    Repo = "https://github.com/azerothcore/mod-ah-bot.git";                      Branch = "master" },
    @{ Name = "mod-arac";                      Repo = "https://github.com/heyitsbench/mod-arac.git";                       Branch = "master" },
    @{ Name = "mod-transmog";                  Repo = "https://github.com/azerothcore/mod-transmog.git";                   Branch = "master" },
    @{ Name = "mod-mounts-on-account";         Repo = "https://github.com/pangolp/mod-mounts-on-account.git";              Branch = "master" },
    @{ Name = "mod-no-hearthstone-cooldown";   Repo = "https://github.com/BytesGalore/mod-no-hearthstone-cooldown.git";    Branch = "main" },
    @{ Name = "mod-flying-mounts-everywhere";  Repo = "https://github.com/Dochoppy/mod-flying-mounts-everywhere.git";      Branch = "main" }
)

New-Item -ItemType Directory -Force ".\modules" | Out-Null

foreach ($module in $modules) {
    $path = ".\modules\$($module.Name)"

    if (Test-Path $path) {
        Write-Host "[OK] $($module.Name) already exists"
    }
    else {
        Write-Host "[CLONE] $($module.Name)"
        git clone --branch $module.Branch --single-branch $module.Repo $path
    }
}

$flyingPath = ".\modules\mod-flying-mounts-everywhere"
$patch = (Resolve-Path ".\patches\flying-playerbot.patch").Path

git -C $flyingPath apply --check $patch 2>$null

if ($LASTEXITCODE -eq 0) {
    git -C $flyingPath apply $patch
    Write-Host "[PATCHED] Flying mounts module for Playerbot core"
}
else {
    git -C $flyingPath apply --reverse --check $patch 2>$null

    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] Flying mounts compatibility patch already applied"
    }
    else {
        Write-Warning "Flying mounts patch could not be applied automatically."
    }
}

Write-Host ""
Write-Host "Module setup complete."

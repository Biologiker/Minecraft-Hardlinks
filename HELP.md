# Help for executing the script

## How to find the right directory for your launcher

### Via your launcher

In almost all my tested launchers you can open the correct folder by right clicking the instance and pressing an option called "Folder", "Open Folder", etc.  

### Manually via the explorer

Most 3rd party launcher store their instances in the AppData/Roaming folder.

You can access this folder by pressing [win + R] and entering %appdata% or by manually opening %appdata% in your Explorer.

#### Prism launcher

You can find your instances under: %appdata%/PrismLauncher/instances/

Now open the the folder with the name of your instance.

In there you will find a folder called ".minecraft".

Thats the folder your looking for.

#### GDLauncher

You can find your instances under: %appdata%/gdlauncher_carbon/data/instances/

Now open the the folder with the name of your instance.

In there you will find a folder called "instance".

Thats the folder your looking for.

#### MultiMC

MultiMC is a little bit different then the other launchers. As it doesn't store its instances in the %appdata% folder but instead in its own installpath.

In its root folder you find a folder called instances.  

In there you will find a folder called ".minecraft".

Thats the folder your looking for.

#### Untested launchers

Every launcher should probably work as long as the folder you want to "convert" to symlinks are all stored in one place inside your instances folder. Since the names of the folders to convert are either named by minecraft itself or the associated mods, naming should not be a problem.

## Creating the root folders

All the root folders have to be stored in one place. In addition (so you can add as many folders as you like) the folders have to have the same name as they would in your minecraft instance. For example: schematics : schematics.

If you want you can store this repo in the same folder or a subfolder as your root folders. If you enable the option to Ignore the Powershell Directory the directory this script is in will automatically be blacklisted. In addition, everything thats not a Folder will be ignored anyway.

Creating symlinks without having the associated mod installed is no problem as the folders just won't be used. For example a shaderpacks folder without installing iris or optifine.

### Recommended root folders to create

- texturepacks / resourcepacks
- shaderpacks (for mods like: optifine, iris, etc.)
- screenshots (i like to have my screenshots in one place)
- schematics (for mods like: Litematica)
- journeymap (if you want to share your journeymap progress and waypoints accross instances)

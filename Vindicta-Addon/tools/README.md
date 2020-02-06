# VINDICTA AddOn

This AddOn was created using the Ace 3 [AddOn Proejct Template](https://github.com/acemod/arma-project-template).
The project template comes with it's own implementation of tools used within the ACE project, such as build and release scripts, SQF validation scripts and more.

### Development Environment

In order to compile the addon you need to setup a P drive, i didnt test it but you might not even need to unpack Arma.
See the [ACE3 documentation](https://ace3mod.com/wiki/development/setting-up-the-development-environment.html) on setting up the development environment.
Note: in step 4 where you make the symbolic links you use "vindicta" instead if "ace"

### Adding new components

Adding a new component to your project is done by copying the example component directory and renaming it. Follow these steps:

- Copy the blank example component directory into the addons directory
- Rename the component directory name (blank -> {your component name})
- Do a search and replace of `blank` by `your component name`. Take care to preserve case sensitivity.
- Do a search and replace of `Blank` by `your component name`  in beautified form, like `Ace` with upper and lower casing. Take care to preserve case sensitivity at search.
- Ensure that the required AddOns in the `config.cpp` file inside your new component are set correctly. You will need at least a requirement to the main component of your project. Any other modifications that your component depends on will also need to be listed here, including your own components that you depend upon.
- Start work on your component.

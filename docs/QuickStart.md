# Quick Start

Currently provide two types of plugins for Tellurium:

## Eclipse Plugin

Tellurium has an update site for Eclipse.

![Screenshots for Eclipse](./res/img/eclipse.screenshot.png)

You can open your Eclipse and find out the `help` menu then select `Install new software...`. 

![Screenshots for Eclipse Installation](./res/img/eclipse.install.1.png)

Once the dialog window poped up, input our updatesite's url:

[https://telluriumlang.github.io/updatesite/](https://telluriumlang.github.io/updatesite/)


Select the Tellurium Plguin and install it. All dependencies will be automatically fetch from the repositories.

![Screenshots for Eclipse Installation](./res/img/eclipse.install.2.png)

## Visual Studio Code Extension

You can find out a preview version VS Code Extension from our release page. 

![Screenshots for VSCode](./res/img/vscode.screenshot.png)

You can manually download the extension from our [release page](https://github.com/telluriumLang/tellurium/releases/) and install the VSIX file into your VS Code environment.

![Screenshots for VSCode Installation](./res/img/vscode.install.1.png)

> **Notice**
> 
> The VS Code extension is an PoC (proof of concept) of the language server protocol and may not supports some of the features in Eclipse plugin. We highly recommend you to try out the Eclipse plugin.

## Environment Configuration

You need to install Java 1.8 before using Tellurium. 

If you need to use the browser driver to launch test, please refer to the document in Selenium: [Link](https://www.selenium.dev/documentation/en/getting_started_with_webdriver/)

## Example project

You can find out an Eclipse style example project in:

[com.telluriumlang.tellurium.example](https://github.com/telluriumLang/tellurium/tree/master/com.telluriumlang.tellurium.example)

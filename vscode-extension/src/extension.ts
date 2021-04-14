import * as path from 'path';
import * as os from 'os';

import { workspace, ExtensionContext, languages, commands, window, Position, Range } from 'vscode';
import {
	LanguageClient,
	LanguageClientOptions,
	ServerOptions
} from 'vscode-languageclient';
import { EmptyTellCodeActionProvider} from './actions/emptyCodeAction';

let client: LanguageClient;

export function activate(context: ExtensionContext) {
	let launcher = os.platform() === 'win32' ? 'main.bat' : 'main';
	let script = context.asAbsolutePath(path.join('languageServer', 'bin', launcher));

	let serverOptions: ServerOptions = {
		run: { command: script },
		debug: { command: script}
	};

	let clientOptions: LanguageClientOptions = {
		documentSelector: [{ scheme: 'te', language: 'tellurium' }],
		synchronize: {
			fileEvents: workspace.createFileSystemWatcher('**/*.*')
		}
	};

	// Create the language client and start the client.
	client = new LanguageClient(
		'telluriumLanguageServer',
		'Tellurium Language Server',
		serverOptions,
		clientOptions
	);

	// Start the client. This will also launch the server
	client.start();

	commands.registerCommand('tellurium.init.project', ()=>{
		let editor = window.activeTextEditor
		if (editor){
			editor.edit(editorBuilder =>{
				if (editor){
					const end = new Position(editor.document.lineCount + 1, 0);
					const text = 'using HtmlUnit driver\n\ntest yourTestCase {\n    \n}';
					editorBuilder.replace(new Range(new Position(0, 0), end), text);
				}
			})
		}
	}
	);

	context.subscriptions.push(
		languages.registerCodeActionsProvider('tellurium', new EmptyTellCodeActionProvider())
	);
}

export function deactivate(): Thenable<void> | undefined {
	if (!client) {
		return undefined;
	}
	return client.stop();
}

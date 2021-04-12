import * as path from 'path';
import * as os from 'os';

import { workspace, ExtensionContext } from 'vscode';
import {
	LanguageClient,
	LanguageClientOptions,
	ServerOptions
} from 'vscode-languageclient';

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
}

export function deactivate(): Thenable<void> | undefined {
	if (!client) {
		return undefined;
	}
	return client.stop();
}

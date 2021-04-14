import {
    CodeActionProvider, 
    TextDocument, 
    Range, 
    CodeActionContext, 
    CancellationToken, 
    Selection, 
    CodeActionKind, 
    CodeAction
} from 'vscode';

export class EmptyTellCodeActionProvider implements CodeActionProvider {

    public static readonly providedCodeActionKinds = [
        CodeActionKind.Source
    ];

    provideCodeActions(document: TextDocument, range: Range | Selection, context: CodeActionContext, token: CancellationToken): CodeAction[] {
        if(document.getText().trim().length < 5){
            return [this.createAction()];
        }
        return [];
    }

    private createAction(): CodeAction {
        const action = new CodeAction('Create a new test set', CodeActionKind.Empty);
        action.command = { command: "tellurium.init.project", title: 'Initialize a Tellurium test set', tooltip: 'It will try to create an empty test set in this file.' };
        action.isPreferred = true;
        return action;
    }
}
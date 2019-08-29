package io.typefox.examples.theia.states.ide.server.codeActions

import io.typefox.examples.theia.states.states.ProcessDefinition
import java.util.List
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.lsp4j.CodeAction
import org.eclipse.lsp4j.CodeActionParams
import org.eclipse.lsp4j.Command
import org.eclipse.lsp4j.Position
import org.eclipse.lsp4j.Range
import org.eclipse.lsp4j.TextEdit
import org.eclipse.lsp4j.WorkspaceEdit
import org.eclipse.lsp4j.jsonrpc.messages.Either
import org.eclipse.xtext.ide.server.Document
import org.eclipse.xtext.ide.server.codeActions.ICodeActionService
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.util.CancelIndicator

class StatesCodeActionService implements ICodeActionService {

	static val CREATE_START_KIND = 'sprotty.create.start'
	static val CREATE_ACTIVITY_KIND = 'sprotty.create.activity'
	static val CREATE_END_KIND = 'sprotty.create.end'

	override getCodeActions(Document document, XtextResource resource, CodeActionParams params, CancelIndicator indicator) {
		var root = resource.contents.head
		if (root instanceof ProcessDefinition)
			createCodeActions(root, params, document)
		 else
		 	emptyList
	}

	private def dispatch List<Either<Command, CodeAction>> createCodeActions(ProcessDefinition stateMachine, CodeActionParams params, Document document) {
		val result = <Either<Command, CodeAction>>newArrayList
		if (CREATE_START_KIND.matchesContext(params)) {
			result.add(Either.forRight(new CodeAction => [
				kind = CREATE_START_KIND
				title = 'new start'
				edit = createInsertWorkspaceEdit(
					stateMachine.eResource.URI,
					document.getPosition(document.contents.length),
					'''«'\n'»start «getNewName('start', stateMachine.elements.map[name])»'''
				)
			]));
		}
		if (CREATE_ACTIVITY_KIND.matchesContext(params)) {
			result.add(Either.forRight(new CodeAction => [
				kind = CREATE_ACTIVITY_KIND
				title = 'new activity'
				edit = createInsertWorkspaceEdit(
					stateMachine.eResource.URI,
					document.getPosition(document.contents.length),
					'''«'\n'»activity «getNewName('activity', stateMachine.elements.map[name])»'''
				)
			]));
		}

		if (CREATE_END_KIND.matchesContext(params)) {
			result.add(Either.forRight(new CodeAction => [
				kind = CREATE_END_KIND
				title = 'new end'
				edit = createInsertWorkspaceEdit(
					stateMachine.eResource.URI,
					document.getPosition(document.contents.length),
					'''«'\n'»end «getNewName('end', stateMachine.elements.map[name])»'''
				)
			]));
		}
		return result
	}

	private def matchesContext(String kind, CodeActionParams params) {
		if (params.context?.only === null)
			return true
		else
			return params.context.only.exists[kind.startsWith(it)]
	}

	private def String getNewName(String prefix, List<? extends String> siblings) {
		for(var i = 0;; i++) {
			val currentName = prefix + i
			if (!siblings.exists[it == currentName])
				return currentName
		}
	}

	private def dispatch List<Either<Command, CodeAction>> createCodeActions(EObject element, CodeActionParams params, Document document) {
		return emptyList
	}

	private def createInsertWorkspaceEdit(URI uri, Position position, String text) {
		new WorkspaceEdit => [
			changes = #{uri.toString -> #[ new TextEdit(new Range(position, position), text) ]}
		]
	}
}
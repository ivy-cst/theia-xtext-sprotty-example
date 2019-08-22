package io.typefox.examples.theia.states.ide.server.codeActions

import com.google.inject.Inject
import io.typefox.examples.theia.states.states.StateMachine
import java.util.List
import org.eclipse.emf.ecore.EObject
import org.eclipse.lsp4j.CodeAction
import org.eclipse.lsp4j.CodeActionParams
import org.eclipse.lsp4j.Command
import org.eclipse.lsp4j.Diagnostic
import org.eclipse.lsp4j.Position
import org.eclipse.lsp4j.Range
import org.eclipse.lsp4j.TextEdit
import org.eclipse.lsp4j.WorkspaceEdit
import org.eclipse.lsp4j.jsonrpc.messages.Either
import org.eclipse.xtext.ide.server.Document
import org.eclipse.xtext.ide.server.UriExtensions
import org.eclipse.xtext.ide.server.codeActions.ICodeActionService
import org.eclipse.xtext.resource.EObjectAtOffsetHelper
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.util.CancelIndicator

import static io.typefox.examples.theia.states.validation.StatesValidator.*

import static extension org.eclipse.xtext.util.Strings.*

class StatesCodeActionService implements ICodeActionService {

	@Inject
	extension UriExtensions

	@Inject EObjectAtOffsetHelper offsetHelper

	static val CREATE_STATE_KIND = 'sprotty.create.state'
	static val CREATE_EVENT_KIND = 'sprotty.create.event'

	override getCodeActions(Document document, XtextResource resource, CodeActionParams params, CancelIndicator indicator) {
		var root = resource.contents.head
		if (root instanceof StateMachine)
			createCodeActions(root, params, document)
		 else
		 	emptyList
	}

	private def dispatch List<Either<Command, CodeAction>> createCodeActions(StateMachine stateMachine, CodeActionParams params, Document document) {
		val resource = stateMachine.eResource as XtextResource
		val uri = resource.URI.toUriString
		val result = <Either<Command, CodeAction>>newArrayList
		if (CREATE_STATE_KIND.matchesContext(params)) {
			result.add(Either.forRight(new CodeAction => [
				kind = CREATE_STATE_KIND
				title = 'new State' 
				edit = createInsertWorkspaceEdit(
					uri, 
					document.getPosition(document.contents.length), 
					'''«'\n'»state «getNewName('state', stateMachine.states.map[name])»'''
				)
			]))
		}
		if (CREATE_EVENT_KIND.matchesContext(params)) {
			result.add(Either.forRight(new CodeAction => [
				kind = CREATE_EVENT_KIND
				title = 'new Event' 
				edit = createInsertWorkspaceEdit(
					uri, 
					document.getPosition(document.contents.length), 
					'''«'\n'»event «getNewName('event', stateMachine.events.map[name])»'''
				)
			]))
		}

		// Quick fixes
		result.addAll(params.context.diagnostics.map[toQuickFixCodeAction(resource, document)].filterNull)

		return result
	}

	private def Either<Command, CodeAction> toQuickFixCodeAction(Diagnostic it, XtextResource resource,
		Document document) {

		if (code == DISCOURAGED_NAME) {
			val object = offsetHelper.resolveElementAt(resource, document.getOffSet(range.start))
			if (object instanceof StateMachine) {
				val uri = resource.URI.toUriString
				val start = range.start
				val end = new Position(start.line, start.character + 1)
				val edit = new TextEdit(new Range(start, end), object.name.substring(0, 1).toFirstUpper)
				return Either.forRight(new CodeAction => [
					kind = 'quickfix'
					title = 'Fix name'
					edit = new WorkspaceEdit => [
						changes = #{uri -> #[edit]}
					]
				])
			}
		}
		return null
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

	private def createInsertWorkspaceEdit(String uri, Position position, String text) {
		new WorkspaceEdit => [
			changes = #{uri -> #[ new TextEdit(new Range(position, position), text) ]}
		]
	}
}

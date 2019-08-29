package io.typefox.examples.theia.states.ide.diagram

import com.google.inject.Inject
import io.typefox.examples.theia.states.states.ProcessElement
import org.eclipse.lsp4j.Range
import org.eclipse.lsp4j.TextEdit
import org.eclipse.lsp4j.WorkspaceEdit
import org.eclipse.sprotty.SModelElement
import org.eclipse.sprotty.SModelIndex
import org.eclipse.sprotty.xtext.ILanguageAwareDiagramServer
import org.eclipse.sprotty.xtext.ReconnectAction
import org.eclipse.sprotty.xtext.WorkspaceEditAction
import org.eclipse.sprotty.xtext.tracing.PositionConverter
import org.eclipse.sprotty.xtext.tracing.XtextTrace
import org.eclipse.xtext.ide.server.ILanguageServerAccess
import org.eclipse.xtext.ide.server.UriExtensions
import org.eclipse.xtext.nodemodel.util.NodeModelUtils

class StatesReconnectHandler {

	@Inject UriExtensions uriExtensions
	@Inject extension PositionConverter

	def handle(ReconnectAction action, ILanguageAwareDiagramServer server) {
		val root = server.diagramState.currentModel
		val extension index = new SModelIndex(root)
		val sedge = action.routableId?.get
		val source = action.newSourceId?.get
//		val target = action.newTargetId?.get
		server.diagramLanguageServer.languageServerAccess.doRead(server.sourceUri, [ context |
			val sourceElement = source?.resolveElement(context) as ProcessElement
//			val targetElement = target?.resolveElement(context) as ProcessElement
			if (sourceElement instanceof ProcessElement) {
				val textEdits = newArrayList
				val fromName = sourceElement.name ?: 'undefined'
				val toName = action.newTargetId;
				val edgeText = '''«'edge '»«fromName» => «toName»'''
				val oldRange = getOldRange(sedge)
//				val newRange = getNewRange(sourceElement as ProcessElement)
//				if (oldRange !== null) {
//					if ((sedge as SEdge).sourceId !== action.newSourceId) {
//						textEdits += new TextEdit(oldRange, '')
//						textEdits += new TextEdit(newRange, edgeText)
//					} else {
//						textEdits += new TextEdit(oldRange, edgeText)
//					}
//				} else {
//					textEdits += new TextEdit(newRange, edgeText)
//				}
				if (oldRange !== null) {
				textEdits += new TextEdit(oldRange, edgeText)
				}
				else {
				textEdits += new TextEdit(getNewRange(sourceElement), '\n' + edgeText)
				}
				val workspaceEdit = new WorkspaceEdit() => [
					changes = #{ server.sourceUri -> textEdits }
				]
				server.dispatch(new WorkspaceEditAction => [
					it.workspaceEdit = workspaceEdit
				]);
				}
			return null
		])
	}

	private def getOldRange(SModelElement routable) {
		if (routable?.trace !== null)
			new XtextTrace(routable.trace).range
		else
			null
	}

	private def getNewRange(ProcessElement sourceElement) {
		val position = NodeModelUtils.findActualNodeFor(sourceElement).endOffset.toPosition(sourceElement)
		return new Range(position, position)
	}


	private def resolveElement(SModelElement sElement, ILanguageServerAccess.Context context) {
		if (sElement.trace !== null) {
			val connectableURI = sElement.trace.toURI
			return context.resource.resourceSet.getEObject(connectableURI, true);
		} else {
			return null
		}
	}

	private def toURI(String path) {
		val parts = path.split('#')
		if(parts.size !== 2)
			throw new IllegalArgumentException('Invalid trace URI ' + path)
		return uriExtensions.toUri(parts.head).appendFragment(parts.last)
	}
}

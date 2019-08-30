package io.typefox.examples.theia.states.ide.diagram

import com.google.inject.Inject
import io.typefox.examples.theia.states.states.Edge
import io.typefox.examples.theia.states.states.ProcessDefinition
import io.typefox.examples.theia.states.states.ProcessElement
import io.typefox.examples.theia.states.states.StatesPackage
import org.eclipse.emf.ecore.EObject
import org.eclipse.sprotty.LayoutOptions
import org.eclipse.sprotty.SEdge
import org.eclipse.sprotty.SGraph
import org.eclipse.sprotty.SLabel
import org.eclipse.sprotty.SModelElement
import org.eclipse.sprotty.SNode
import org.eclipse.sprotty.SPort
import org.eclipse.sprotty.xtext.IDiagramGenerator
import org.eclipse.sprotty.xtext.SIssueMarkerDecorator
import org.eclipse.sprotty.xtext.tracing.ITraceProvider

class StatesDiagramGenerator implements IDiagramGenerator {

	@Inject extension ITraceProvider
	@Inject extension SIssueMarkerDecorator

	override generate(Context context) {
		(context.resource.contents.head as ProcessDefinition).toSGraph(context)
	}

	def toSGraph(ProcessDefinition sm, extension Context context) {
		(new SGraph [
			id = idCache.uniqueId(sm, sm.name)
			children = (sm.elements.map[toSNode(context)]
					  + sm.edges.map[toSEdge(context)]
			).toList
		]).traceAndMark(sm, context)
	}

	def SNode toSNode(ProcessElement state, extension Context context) {
		val theId = idCache.uniqueId(state, state.name)
		(new SNode [
			id = theId
			children =  #[
				(new SLabel [
					id = idCache.uniqueId(theId + '.label')
					text = state.name
				]).trace(state),
				new SPort [
					id = idCache.uniqueId(theId + '.newTransition')
				]
			]
			layout = 'stack'
			layoutOptions = new LayoutOptions [
				paddingTop = 10.0
				paddingBottom = 10.0
				paddingLeft = 10.0
				paddingRight = 10.0

			]
		]).traceAndMark(state, context)
	}

	def SEdge toSEdge(Edge transition, extension Context context) {
		(new SEdge [
			sourceId = idCache.getId(transition.from)
			targetId = idCache.getId(transition.to)
			val theId = idCache.uniqueId(transition, sourceId + ':' + targetId)
			id = theId
			children = #[
				(new SLabel [
					id = idCache.uniqueId(theId + '.label')
					type = 'label:xref'
					text = ''
				]).trace(transition, StatesPackage.Literals.EDGE__FROM, -1)
			]
		]).traceAndMark(transition, context)
	}

	def <T extends SModelElement> T traceAndMark(T sElement, EObject element, Context context) {
		sElement.trace(element).addIssueMarkers(element, context)
	}
}
package io.typefox.examples.theia.states.ide.diagram

import org.eclipse.elk.alg.layered.options.LayeredOptions
import org.eclipse.elk.core.options.CoreOptions
import org.eclipse.elk.core.options.Direction
import org.eclipse.elk.core.options.PortAlignment
import org.eclipse.elk.core.options.PortConstraints
import org.eclipse.elk.core.options.PortSide
import org.eclipse.sprotty.SGraph
import org.eclipse.sprotty.SModelRoot
import org.eclipse.sprotty.layout.ElkLayoutEngine
import org.eclipse.sprotty.layout.SprottyLayoutConfigurator

class StatesLayoutEngine extends ElkLayoutEngine {

	override layout(SModelRoot root) {
		if (root instanceof SGraph) {
			val configurator = new SprottyLayoutConfigurator
			configurator.configureByType('graph')
				.setProperty(CoreOptions.DIRECTION, Direction.RIGHT)
				.setProperty(CoreOptions.SPACING_NODE_NODE, 100.0)
				.setProperty(CoreOptions.SPACING_EDGE_NODE, 100.0)
				.setProperty(CoreOptions.SPACING_COMPONENT_COMPONENT, 100.0)
				.setProperty(LayeredOptions.SPACING_EDGE_NODE_BETWEEN_LAYERS, 30.0)
				.setProperty(CoreOptions.FONT_SIZE, 30)
			configurator.configureByType('node')
				.setProperty(CoreOptions.PORT_ALIGNMENT_DEFAULT, PortAlignment.CENTER)
				.setProperty(CoreOptions.SPACING_COMPONENT_COMPONENT, 100.0)
				.setProperty(CoreOptions.PORT_CONSTRAINTS, PortConstraints.FIXED_SIDE)
				.setProperty(CoreOptions.SPACING_EDGE_NODE, 100.0)
				.setProperty(CoreOptions.FONT_SIZE, 30)
			configurator.configureByType('port')
				.setProperty(CoreOptions.PORT_SIDE, PortSide.EAST)
				.setProperty((CoreOptions.PORT_BORDER_OFFSET), 1.0)
			layout(root, configurator)
		}
	}
}
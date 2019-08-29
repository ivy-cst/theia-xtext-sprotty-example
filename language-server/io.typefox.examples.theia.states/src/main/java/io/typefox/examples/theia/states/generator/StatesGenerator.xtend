/*
 * generated by Xtext 2.16.0
 */
package io.typefox.examples.theia.states.generator

import io.typefox.examples.theia.states.states.ProcessDefinition
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.AbstractGenerator
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext

/**
 * Generates code from your model files on save.
 *
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#code-generation
 */
class StatesGenerator extends AbstractGenerator {

	override void doGenerate(Resource resource, IFileSystemAccess2 fsa, IGeneratorContext context) {
//		val stateMachine = resource.contents.head as ProcessDefinition
//		fsa.generateFile(stateMachine.name + ".java", toJavaCode(stateMachine))
	}

	def className(ProcessDefinition statemachine) {
		statemachine.name
	}

//	def toJavaCode(ProcessDefinition sm) '''
//		import java.io.BufferedReader;
//		import java.io.IOException;
//		import java.io.InputStreamReader;
//
//		public class «sm.className» {
//
//			public static void main(String[] args) {
//				new «sm.className»().run();
//			}
//
//			protected void run() {
//				String currentState = "«sm.states.head?.name»";
//				String lastEvent = null;
//				while (true) {
//					«FOR state : sm.states»
//						«state.generateCode»
//					«ENDFOR»
//				}
//			}
//
//			private String receiveEvent() {
//				System.out.flush();
//				BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
//				try {
//					return br.readLine();
//				} catch (IOException ioe) {
//					System.out.println("Problem reading input");
//					return "";
//				}
//			}
//		}
//	'''
//
//	def generateCode(State state) '''
//		if (currentState.equals("«state.name»")) {
//			System.out.println("Your are now in state '«state.name»'. Possible events are [«
//				state.transitions.map(t | t.event.name).join(', ')»].");
//			lastEvent = receiveEvent();
//			«FOR t : state.transitions»
//				if ("«t.event.name»".equals(lastEvent)) {
//					currentState = "«t.state.name»";
//				}
//			«ENDFOR»
//		}
//	'''
}

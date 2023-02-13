/*
 * generated by Xtext 2.24.0
 */
package com.regnosys.rosetta.ui.contentassist

import com.google.common.base.Function
import com.google.common.base.Predicate
import com.google.common.base.Predicates
import com.google.inject.Inject
import com.regnosys.rosetta.RosettaExtensions
import com.regnosys.rosetta.rosetta.expression.RosettaBinaryOperation
import com.regnosys.rosetta.rosetta.RosettaModel
import com.regnosys.rosetta.rosetta.simple.Operation
import com.regnosys.rosetta.scoping.RosettaScopeProvider
import com.regnosys.rosetta.types.REnumType
import com.regnosys.rosetta.types.RosettaExpectedTypeProvider
import com.regnosys.rosetta.types.RosettaTypeProvider
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EReference
import org.eclipse.jface.text.contentassist.ICompletionProposal
import org.eclipse.xtext.EcoreUtil2
import org.eclipse.xtext.RuleCall
import org.eclipse.xtext.naming.IQualifiedNameProvider
import org.eclipse.xtext.resource.EObjectDescription
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.resource.IResourceDescriptions
import org.eclipse.xtext.ui.editor.contentassist.ConfigurableCompletionProposal
import org.eclipse.xtext.ui.editor.contentassist.ContentAssistContext
import org.eclipse.xtext.ui.editor.contentassist.ICompletionProposalAcceptor

import static com.regnosys.rosetta.rosetta.RosettaPackage.Literals.*
import static com.regnosys.rosetta.rosetta.simple.SimplePackage.Literals.*
import static com.regnosys.rosetta.rosetta.expression.ExpressionPackage.Literals.*

/**
 * See https://www.eclipse.org/Xtext/documentation/310_eclipse_support.html#content-assist
 * on how to customize the content assistant.
 */
class RosettaProposalProvider extends AbstractRosettaProposalProvider {

	@Inject extension RosettaTypeProvider
	@Inject extension RosettaExpectedTypeProvider
	@Inject extension RosettaExtensions
	
	@Inject IQualifiedNameProvider qNames
	@Inject IResourceDescriptions resDescr
	
	override protected lookupCrossReference(
		EObject model,
		EReference reference,
		ICompletionProposalAcceptor acceptor,
		Predicate<IEObjectDescription> filter,
		Function<IEObjectDescription, ICompletionProposal> proposalFactory
	) {
		val expectedType = switch (model) {
			Operation case reference == ROSETTA_SYMBOL_REFERENCE__SYMBOL: {
				model.getExpectedType(OPERATION__EXPRESSION)
			}
			RosettaBinaryOperation: {
				model.left?.RType
			}
		}
		if (expectedType instanceof REnumType) {
			expectedType.enumeration.allEnumValues.forEach [ enumValue |
				val proposal = proposalFactory.apply(
						EObjectDescription.create(qNames.getFullyQualifiedName(enumValue), enumValue))
				if(proposal instanceof ConfigurableCompletionProposal) {
					proposal.replacementString = '''«enumValue.enumeration.name» -> «enumValue.name»'''
					proposal.priority = proposal.priority + 5
				}
				acceptor.accept(proposal)
			]
		}
		super.lookupCrossReference(model, reference, acceptor, filter, proposalFactory)
	}
	
	override void complete_QualifiedNameWithWildcard(EObject model, RuleCall ruleCall, ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
		val rosettaModel = EcoreUtil2.getContainerOfType(model, RosettaModel)
		val Predicate<IEObjectDescription> filter = if (rosettaModel !== null) {
				[ IEObjectDescription descr |
					val name = descr.name.toString
					RosettaScopeProvider.LIB_NAMESPACE != name && name != rosettaModel.name &&
						!rosettaModel.imports.exists[import|name == import.importedNamespace]
				]
			} else
				Predicates.alwaysTrue()
		resDescr.getExportedObjectsByType(ROSETTA_MODEL).filter(filter).forEach [
			if (acceptor.canAcceptMoreProposals) {
				var displayString = qualifiedNameConverter.toString(it.getQualifiedName())
				val text = it.name + '.*'
				var image = getImage(it)
				val proposal = createCompletionProposal(text, displayString, image, context)
				acceptor.accept(proposal)
			}
		]
	}
	
}

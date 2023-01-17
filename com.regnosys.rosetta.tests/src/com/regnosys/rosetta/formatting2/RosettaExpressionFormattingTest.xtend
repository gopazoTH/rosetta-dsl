package com.regnosys.rosetta.formatting2

import org.junit.jupiter.api.Test
import javax.inject.Inject

import org.junit.jupiter.api.^extension.ExtendWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.eclipse.xtext.testing.InjectWith
import com.regnosys.rosetta.tests.RosettaInjectorProvider
import org.eclipse.xtext.testing.formatter.FormatterTestHelper

@ExtendWith(InjectionExtension)
@InjectWith(RosettaInjectorProvider)
class RosettaExpressionFormattingTest {
	@Inject
	extension FormatterTestHelper
	
	@Test
	def void testIndexOutOfBounds() {
		assertFormatted[
			it.toBeFormatted = '''
			True exists
			'''
		]
	}
}
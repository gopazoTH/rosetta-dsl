package com.regnosys.rosetta.ide.tests

import org.eclipse.xtext.testing.AbstractLanguageServerTest
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtext.testing.TextDocumentPositionConfiguration
import org.eclipse.lsp4j.InlayHint
import java.util.List
import org.eclipse.lsp4j.InlayHintParams
import org.eclipse.lsp4j.TextDocumentIdentifier
import org.eclipse.lsp4j.Range
import org.eclipse.lsp4j.Position
import org.eclipse.xtext.resource.IResourceServiceProvider
import org.eclipse.xtext.LanguageInfo
import org.eclipse.lsp4j.jsonrpc.services.ServiceEndpoints
import java.io.File
import org.junit.jupiter.api.BeforeEach
import org.junit.Before
import org.eclipse.lsp4j.SemanticTokensParams
import javax.inject.Inject
import com.regnosys.rosetta.ide.semantictokens.SemanticToken
import com.regnosys.rosetta.ide.server.RosettaLanguageServerImpl
import com.regnosys.rosetta.tests.util.ModelHelper
import org.eclipse.xtext.testing.TextDocumentConfiguration
import org.eclipse.xtext.testing.FileInfo
import java.nio.charset.StandardCharsets

abstract class AbstractRosettaLanguageServerTest extends AbstractLanguageServerTest {
	@Inject extension ModelHelper
	
	new() {
		super("rosetta")
	}
	
	@Before @BeforeEach
	override void setup() {
		val injector = new RosettaServerInjectorProvider().getInjector()
		injector.injectMembers(this)

		val resourceServiceProvider = resourceServerProviderRegistry.extensionToFactoryMap.get(fileExtension)
		if (resourceServiceProvider instanceof IResourceServiceProvider)
			languageInfo = resourceServiceProvider.get(LanguageInfo)

		// register notification callbacks
		languageServer.connect(ServiceEndpoints.toServiceObject(this, languageClientClass))
		// initialize
		languageServer.supportedMethods()

		// create workingdir
		root = new File(new File("").absoluteFile, TEST_PROJECT_PATH)
	}
	
	@Accessors static class TestInlayHintsConfiguration extends TextDocumentPositionConfiguration {
		String expectedInlayHintItems = ''
		(List<? extends InlayHint>) => void assertInlayHints = null
		Range range = new Range(new Position(0, 0), new Position(Integer.MAX_VALUE, Integer.MAX_VALUE))
		boolean assertNoIssues = true
	}
	
	protected def void testInlayHint((TestInlayHintsConfiguration)=>void configurator) {
		val extension configuration = new TestInlayHintsConfiguration
		configuration.filePath = 'MyModel.' + fileExtension
		configurator.apply(configuration)
		val filePath = initializeContext(configuration).uri
		val range = configuration.range
		val inlayHints = languageServer.inlayHint(new InlayHintParams(
			new TextDocumentIdentifier(filePath),
			range
		))
		val result = inlayHints.get.map[languageServer.resolveInlayHint(it).get].toList

		if (configuration.assertNoIssues) {
			configuration.model.parseRosettaWithNoIssues
		}
		if (configuration.assertInlayHints !== null) {
			configuration.assertInlayHints.apply(result)
		} else {
			assertEquals(expectedInlayHintItems, result.toExpectation)
		}
	}
	
	@Accessors static class TestSemanticTokensConfiguration extends TextDocumentPositionConfiguration {
		String expectedSemanticTokenItems = ''
		(List<? extends SemanticToken>) => void assertSemanticTokens = null
		boolean assertNoIssues = true
	}
	
	protected def void testSemanticToken((TestSemanticTokensConfiguration)=>void configurator) {
		val extension configuration = new TestSemanticTokensConfiguration
		configuration.filePath = 'MyModel.' + fileExtension
		configurator.apply(configuration)
		val filePath = initializeContext(configuration).uri
		val semanticTokens = languageServer.requestManager.runRead[cancelIndicator |
			(languageServer as RosettaLanguageServerImpl).semanticTokens(
				new SemanticTokensParams(
					new TextDocumentIdentifier(filePath)
				),
				cancelIndicator
			)
		]
		val result = semanticTokens.get.sort

		if (configuration.assertNoIssues) {
			configuration.model.parseRosettaWithNoIssues
		}
		if (configuration.assertSemanticTokens !== null) {
			configuration.assertSemanticTokens.apply(result)
		} else {
			assertEquals(expectedSemanticTokenItems, result.toExpectation)
		}
	}
	
	protected override FileInfo initializeContext(TextDocumentConfiguration configuration) {
		val filePath = super.initializeContext(configuration);
		writeModelFile('basictypes.rosetta')
		writeModelFile('annotations.rosetta')
		return filePath
	}
	private def void writeModelFile(String fileName) {
		val content = new String(this.getClass().getResourceAsStream('''/model/«fileName»''').readAllBytes(), StandardCharsets.UTF_8);
		val filePath = fileName.writeFile(content);
		open(filePath, content);
	}
}
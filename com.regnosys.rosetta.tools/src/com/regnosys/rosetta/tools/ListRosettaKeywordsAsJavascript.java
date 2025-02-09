package com.regnosys.rosetta.tools;

import com.google.inject.Injector;
import com.regnosys.rosetta.RosettaStandaloneSetup;
import com.regnosys.rosetta.services.RosettaGrammarAccess;

import java.util.Set;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

import org.eclipse.xtext.Grammar;
import org.eclipse.xtext.GrammarUtil;

public class ListRosettaKeywordsAsJavascript {

	public static void main(String[] args) {
		Injector inj = new RosettaStandaloneSetup().createInjectorAndDoEMFRegistration();
		
		RosettaGrammarAccess grammarAccess = inj.getInstance(RosettaGrammarAccess.class);
		Grammar grammar = grammarAccess.getGrammar();
		Set<String> keywords = GrammarUtil.getAllKeywords(grammar);
		
		System.out.println(
				keywords.stream()
					.filter(keyword -> keyword.matches(".*[a-zA-Z].*")) // only match keywords that at least contain one alpha character
					.map(keyword -> "'" + keyword + "'")
					.collect(Collectors.joining(", "))
		);
	}

}

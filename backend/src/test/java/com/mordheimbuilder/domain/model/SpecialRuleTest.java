package com.mordheimbuilder.domain.model;

import org.junit.jupiter.api.Test;

import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;

public class SpecialRuleTest {

    @Test
    void shouldCreateRuleWhenAllFieldsAreValid(){
        //Arrange + Act: on construit l'objet
        SpecialRule rule = new SpecialRule(UUID.randomUUID(),"parade", "Annule une attaque");

        //Assert : on vérifie le résultat
        assertEquals("parade",rule.name());
    }

    @Test
    void shouldRejectBlankName(){
        assertThrows(IllegalArgumentException.class,
                () -> new SpecialRule(UUID.randomUUID()," ", "Une description"));
    }

    @Test
    void shouldRejectBlankDescription(){
        assertThrows(IllegalArgumentException.class,
                () -> new SpecialRule(UUID.randomUUID(),"parade"," ") );
    }

}

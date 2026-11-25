package com.mordheimbuilder.application.usecase;

import com.mordheimbuilder.domain.model.Weapon;
import com.mordheimbuilder.domain.port.out.WeaponRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
public class ListWeaponsServiceMockitoTest {

    @Mock
    private WeaponRepository weaponRepository;

    private ListWeaponsService service;

    //methode utilitaire
    private static Weapon aWeapon(){

        return new Weapon(UUID.randomUUID(),"Epee","Utilisateur","corps à corps",6,"Commun", false, true, List.of());
    }

    @BeforeEach
    void setUp(){
        service = new ListWeaponsService(weaponRepository);
    }

    @Test
    void shouldReturnWeaponsProvidedByRepository() {
        //Arrange
        List<Weapon> weaponsList = List.of(
                aWeapon(),
                aWeapon()
        );
        when(weaponRepository.findAll()).thenReturn(weaponsList);

        //Act
        List<Weapon> result =  service.listWeapons();

        //Assert
        assertEquals(weaponsList,result);
        verify(weaponRepository).findAll();
    }

    @Test
    void shouldReturnEmptyListWhenRepositoryIsEmpty(){
        //Arrange
        List<Weapon> weaponList = List.of();
        when(weaponRepository.findAll()).thenReturn(weaponList);

        //Act
        List<Weapon> result = service.listWeapons();

        //Assert
        assertEquals(weaponList,result);
        verify(weaponRepository).findAll();
    }

}

package com.mordheimbuilder.application.port.in;

import com.mordheimbuilder.domain.model.Weapon;

import java.util.List;

public interface ListWeaponsUseCase {

    List<Weapon> listWeapons();
}

# Fiche récapitulative : tests unitaires avec JUnit 5 et Mockito

> Fiche personnelle du projet Mordheim Builder. Les exemples reprennent `ListWeaponsService` et `WeaponRepository`.

---

## 1. À quoi sert Mockito

Tester une classe **isolément**, sans ses vraies dépendances (base de données, réseau, autre service). Mockito génère à la volée un **faux objet** qui implémente l'interface de la dépendance, sans qu'on écrive de classe annexe.

Ça n'a de sens que parce que le code est conçu pour ça : le service reçoit ses dépendances **par le constructeur** et ne connaît que des interfaces (ports). C'est l'inversion de dépendances de l'architecture hexagonale.

## 2. Vocabulaire

| Terme | Sens |
|---|---|
| **Mock** | Faux objet généré par Mockito, qui remplace une dépendance. |
| **Stub / stubbing** | Définir ce que le mock répond : `when(...).thenReturn(...)`. |
| **Verify** | Vérifier qu'une méthode du mock a été appelée (ou pas) : `verify(...)`. |
| **Fake** | Vraie implémentation simplifiée, écrite à la main (par exemple un repository en mémoire). |
| **Spy** | Vrai objet dont on peut surveiller ou remplacer quelques méthodes. À éviter au départ. |

## 3. La grille à suivre pour chaque test

Avant de taper du code :

1. **Quelle classe je teste ?** Je la crée **pour de vrai** (`new`).
2. **De quoi dépend-elle ?** (les paramètres de son constructeur) Chacune devient un `@Mock`.
3. **Que doit-elle renvoyer ou faire ?** Ça donne l'assertion.
4. **Que doivent répondre ses dépendances pour ce scénario ?** Ça donne les `when(...)`.
5. **Arrange / Act / Assert**, dans cet ordre, séparés par une ligne vide.

> **Règle d'or : on ne mocke jamais la classe testée, seulement ses dépendances.**
> Si un test échoue avec « méthode jamais appelée » ou `UnnecessaryStubbingException`, la première chose à vérifier est ce choix entre « vrai » et « mock ».

## 4. Squelette de test

```java
@ExtendWith(MockitoExtension.class)
class ListWeaponsServiceMockitoTest {

    @Mock
    private WeaponRepository weaponRepository;   // la dépendance : un mock

    private ListWeaponsService service;          // la classe testée : un vrai objet

    @BeforeEach
    void setUp() {
        service = new ListWeaponsService(weaponRepository);
    }

    @Test
    void shouldReturnWeaponsProvidedByRepository() {
        // Arrange
        List<Weapon> weapons = List.of(aWeapon(), aWeapon());
        when(weaponRepository.findAll()).thenReturn(weapons);

        // Act
        List<Weapon> result = service.listWeapons();

        // Assert
        assertEquals(weapons, result);          // (expected, actual)
        verify(weaponRepository).findAll();
    }
}
```

## 5. L'essentiel de l'API

| Besoin | Code |
|---|---|
| Activer Mockito avec JUnit 5 | `@ExtendWith(MockitoExtension.class)` sur la classe |
| Créer un mock | `@Mock` sur un champ (ou `Mockito.mock(X.class)`) |
| Renvoyer une valeur | `when(mock.methode()).thenReturn(valeur)` |
| Lever une exception | `when(mock.methode()).thenThrow(new IllegalStateException("..."))` |
| Méthode `void` qui lève une exception | `doThrow(new ...).when(mock).methode()` |
| Vérifier un appel | `verify(mock).methode()` |
| Vérifier le nombre d'appels | `verify(mock, times(2)).methode()` |
| Vérifier qu'un appel n'a **pas** eu lieu | `verify(mock, never()).methode()` |
| N'importe quel argument | `any()`, `anyString()`, `eq(valeur)` |
| Construire l'objet testé avec les mocks | `@InjectMocks` (pratique, mais moins explicite que `new`) |

Tester un cas d'erreur :

```java
when(weaponRepository.findAll()).thenThrow(new IllegalStateException("db down"));
assertThrows(IllegalStateException.class, () -> service.listWeapons());
```

**Les matchers** (`any()`, `eq()`...) : dès qu'on en utilise un pour un argument, **tous** les arguments de l'appel doivent en utiliser un (`eq(valeur)` pour une valeur exacte).

**Valeurs par défaut d'un mock non configuré** : liste ou ensemble vide pour une collection, `Optional.empty()` pour un `Optional`, `0` / `false` pour les primitifs, `null` pour les autres objets. C'est une source classique de `NullPointerException` déroutantes.

## 6. Le mode strict

Avec `MockitoExtension`, si on écrit un `when(...)` que le code testé n'utilise jamais, le test **échoue** (`UnnecessaryStubbingException`). C'est voulu : un stub inutile est du code de test mort (reste d'un refactoring) ou le signe qu'on ne teste pas le scénario qu'on croit.

## 7. `verify` : utile, mais pas toujours

- `verify` prouve qu'un appel a eu lieu, **pas que le résultat est correct**.
- Quand l'assertion porte déjà sur le résultat d'un `when`, `verify` est redondant (le stub strict garantit déjà l'appel).
- Il devient indispensable pour les méthodes **sans valeur de retour** (`save`, `delete`...) et pour vérifier qu'un appel n'a **pas** eu lieu.
- En abuser **couple le test à l'implémentation** : un simple refactoring, sans changement de comportement, le fait casser.

Règle pratique : tester d'abord **ce que le code produit** (résultat, état), et ne vérifier **comment** il fonctionne que lorsque l'effet de bord est le comportement attendu.

## 8. Mock ou fake ?

| | Mock (Mockito) | Fake (écrit à la main) |
|---|---|---|
| Écriture | très peu de code | une classe à maintenir |
| Cas simple (lecture seule) | idéal | possible, mais plus verbeux |
| Plusieurs opérations liées (sauvegarder puis relire) | `when` répétés, vite lourd | un fake en mémoire est plus clair et réutilisable |
| Risque | couplage à l'implémentation via `verify` | divergence entre le fake et le vrai comportement |

## 9. Où Mockito ne sert pas dans ce projet

- **Domaine** (`Weapon`, `SpecialRule`) : aucune dépendance, un test JUnit pur suffit.
- **Adaptateur JPA** : on ne mocke pas la base, on la teste pour de vrai avec **Testcontainers** et PostgreSQL. Mocker JPA ne prouverait rien sur les requêtes.
- **Types valeur** (`record`, `List`, `String`) : on les crée normalement, on ne les mocke pas.

## 10. Erreurs fréquentes

| Symptôme | Cause probable |
|---|---|
| `Wanted but not invoked` | la classe testée est un mock, ou le code n'appelle pas la dépendance |
| `UnnecessaryStubbingException` | un `when` n'est pas utilisé par le code testé |
| `NullPointerException` dans le test | un mock non configuré renvoie `null` pour un objet |
| Le test ne peut jamais échouer | assertion absente, ou classe testée mockée |
| Le test casse à chaque refactoring | trop de `verify` sur le fonctionnement interne |
| Avertissement `Sharing is only supported for boot loader classes` | message de la JVM lié à l'agent de Mockito, sans effet sur les résultats |

## 11. Questions d'entretien

**C'est quoi un mock ? Quelle différence avec un fake ?**
Un mock est généré par un framework et programmé test par test ; un fake est une vraie implémentation simplifiée, écrite à la main (par exemple un repository en mémoire).

**Pourquoi ne mockes-tu pas la classe que tu testes ?**
Parce qu'on testerait un faux : ses méthodes ne font plus leur vrai travail et le test ne prouve rien du code réel.

**Que fait `verify` ? Quel est le risque ?**
Il vérifie qu'une méthode a été appelée. Le risque est de coupler le test à l'implémentation : le test casse au premier refactoring alors que le comportement n'a pas changé.

**À quoi sert le mode strict ?**
À faire échouer un test dont un `when` n'est jamais utilisé, donc à repérer du code de test mort.

**Pourquoi ne mockes-tu pas ta base de données dans les tests de persistance ?**
Un mock ne vérifie rien des vraies requêtes ni du mapping. Je teste l'adaptateur JPA contre un vrai PostgreSQL avec Testcontainers.

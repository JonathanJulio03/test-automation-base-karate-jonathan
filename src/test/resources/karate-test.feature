Feature: Super Simple API Test

  Background:
    * url apiUrl
    * def uuid = function() { return java.util.UUID.randomUUID() + '' }
    * def createSuccess = read('classpath:data/create_success.json')
    * def createDuplicate = read('classpath:data/create_duplicate.json')
    * def createMissing = read('classpath:data/create_missing_fields.json')
    * def updateSuccess = read('classpath:data/update_success.json')
    * def updateNotFound = read('classpath:data/update_not_found.json')

  Scenario: Obtener todos los personajes
    Given path '/characters'
    When method get
    Then status 200
    And assert response != null
    And assert response.length > 0
    * def names = response.map(x => x.name)
    * match names contains 'Iron Man'
    * def ironman = response.find(x => x.name == 'Iron Man')
    * match ironman.alterego == 'Tony Stark'
    * match ironman.powers contains any ['Tech Suit', 'Armor']
    * match ironman.description != null

  Scenario: Obtener personaje por ID (exitoso)
    * def name = 'Thunder Seer ' + uuid()
    * def payload = createSuccess
    * set payload.name = name
    Given path '/characters'
    And request payload
    When method post
    Then status 201
    * def characterId = response.id
    * match response.name == name
    * match response.id != null
    Given path '/characters/' + characterId
    When method get
    Then status 200
    And match response.id == characterId
    And match response.name == name
    And match response.powers == payload.powers
    And match response.description == payload.description

  Scenario: Obtener personaje por ID (no existe)
    Given path '/characters/88888888'
    When method get
    Then status 404
    And match response.error == 'Character not found'

  Scenario: Crear personaje (exitoso)
    * def name = 'Mystic Blade ' + uuid()
    * def payload = createSuccess
    * set payload.name = name
    Given path '/characters'
    And request payload
    When method post
    Then status 201
    And match response.name == name
    And match response.powers contains 'Tech Suit'
    And match response.id != null
    And match response.alterego == payload.alterego

  Scenario: Crear personaje (nombre duplicado)
    * def name = 'Shadow Brute ' + uuid()
    * def payload = createDuplicate
    * set payload.name = name
    Given path '/characters'
    And request payload
    When method post
    Then status 201
    * def secondPayload = createDuplicate
    * set secondPayload.name = name
    * set secondPayload.alterego = 'Another Brute'
    Given path '/characters'
    And request secondPayload
    When method post
    Then status 400
    And match response.error == 'Character name already exists'

  Scenario: Crear personaje (faltan campos requeridos)
    Given path '/characters'
    And request createMissing
    When method post
    Then status 400
    And match response.name == 'Name is required'
    And match response.alterego == 'Alterego is required'
    And match response.description == 'Description is required'

  Scenario: Actualizar personaje (exitoso)
    * def name = 'Captain Prism ' + uuid()
    * def createPayload = updateSuccess
    * set createPayload.name = name
    * set createPayload.description = 'Light warrior'
    * set createPayload.powers = ['Prism Shield']
    Given path '/characters'
    And request createPayload
    When method post
    Then status 201
    * def characterId = response.id
    * def updatePayload = updateSuccess
    * set updatePayload.name = name
    * set updatePayload.description = 'Upgraded prism tactics'
    * set updatePayload.powers = ['Prism Shield', 'Tactical Mind']
    Given path '/characters/' + characterId
    And request updatePayload
    When method put
    Then status 200
    And match response.description == 'Upgraded prism tactics'
    And match response.powers contains 'Tactical Mind'
    And match response.id == characterId
    Given path '/characters/' + characterId
    When method get
    Then status 200
    And match response.powers contains 'Tactical Mind'

  Scenario: Actualizar personaje (no existe)
    Given path '/characters/77777777'
    And request updateNotFound
    When method put
    Then status 404
    And match response.error == 'Character not found'

  Scenario: Eliminar personaje (exitoso)
    * def name = 'Silent Viper ' + uuid()
    * def payload = createSuccess
    * set payload.name = name
    * set payload.alterego = 'Selene Voss'
    * set payload.description = 'Elite silent assassin'
    * set payload.powers = ['Stealth']
    Given path '/characters'
    And request payload
    When method post
    Then status 201
    * def characterId = response.id
    Given path '/characters/' + characterId
    When method delete
    Then status 204
    Given path '/characters/' + characterId
    When method get
    Then status 404
    And match response.error == 'Character not found'

  Scenario: Eliminar personaje (no existe)
    Given path '/characters/123456789'
    When method delete
    Then status 404
    And match response.error == 'Character not found'
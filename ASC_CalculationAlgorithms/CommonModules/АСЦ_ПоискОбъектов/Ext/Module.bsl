﻿
// Возвращает ссылку на контрагента
// Порядок поиска
//  1. ИНН + КПП, если заполены ИНН и КПП
//  2. ИНН, если поиск по ИНН+КПП не выдал результата или если КПП не заполнено
//  Если при поиске по ИНН найдено более 1 контрагента, то используется параметр "ВозвращатьПервого"
//  Если по ИНН+КПП не нашли, но по ИНН нашли, то проверяется совпадает ли КПП (возможно ошибка в КПП)
//  3. Наименование
//
// Параметры:
//	Наименование - Строка
//	ИНН - Строка
//	КПП - Строка
//	ТекстОшибки - Строка, куда возвращается описание ошибки поиска
//	ВозвращатьПервого - Булево, если найдено более 1 контрагента, то возвращается первый, иначе пустая ссылка
//
// Возвращаемое значение: СправочникСсылка.Контрагенты
//
Функция НайтиКонтрагента(Наименование, ИНН, КПП, ТекстОшибки = "", ВозвращатьПервого = Ложь) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Параметры.Вставить("Наименование", Наименование);
	Запрос.Параметры.Вставить("ИНН",          ИНН);
	Запрос.Параметры.Вставить("КПП",          КПП);
	
	Если ЗначениеЗаполнено(ИНН) Тогда
		
		Если ЗначениеЗаполнено(КПП) Тогда
			
			Запрос.Текст =
			"ВЫБРАТЬ ПЕРВЫЕ 1
			|	Спр.Ссылка КАК Ссылка
			|ИЗ
			|	Справочник.Контрагенты КАК Спр
			|ГДЕ
			|	НЕ Спр.ЭтоГруппа
			|	И НЕ Спр.ПометкаУдаления
			|	И Спр.ИНН = &ИНН
			|	И Спр.КПП = &КПП";
			
		Иначе
		
			Запрос.Текст =
			"ВЫБРАТЬ ПЕРВЫЕ 1
			|	Спр.Ссылка КАК Ссылка,
			|	Спр.КПП КАК КПП
			|ИЗ
			|	Справочник.Контрагенты КАК Спр
			|ГДЕ
			|	НЕ Спр.ЭтоГруппа
			|	И НЕ Спр.ПометкаУдаления
			|	И Спр.ИНН = &ИНН";
			
		КонецЕсли;	
		
	Иначе
		
		// По наименованию ищем любой
		Запрос.Текст =
		"ВЫБРАТЬ ПЕРВЫЕ 1
		|	Спр.Ссылка КАК Ссылка
		|ИЗ
		|	Справочник.Контрагенты КАК Спр
		|ГДЕ
		|	НЕ Спр.ЭтоГруппа
		|	И НЕ Спр.ПометкаУдаления
		|	И Спр.Наименование = &Наименование";
		
	КонецЕсли;	
	
	Результат = Запрос.Выполнить();
	Если НЕ Результат.Пустой() Тогда
		Возврат Результат.Выгрузить()[0][0];
	Иначе	
		ТекстОшибки = "Не найден контрагент: " + Наименование + ", ИНН: " + ИНН + ", КПП: " + КПП;
		Возврат Справочники.Контрагенты.ПустаяСсылка();
	КонецЕсли;
			
КонецФункции

// Возвращает ссылку на контрагента.
// Если контрагент отсутствует, то создается новый
// Для поиска вызывается функция НайтиКонтрагента
//
// Параметры:
//	Данные - Структура
//		Контрагент - Строка, наименование контрагента
//		КонтрагентИНН - Строка	
//		КонтрагентКПП - Строка
//		КонтрагентПаспортСерия - Строка
//		КонтрагентПаспортНомер - Строка
//		КонтрагентПаспортДата - Строка
//	Параметры - Структура
//		КонтрагентРодительФЛ - СправочникСсылка.Контрагенты
//		КонтрагентРодительЮЛ - СправочникСсылка.Контрагенты
//	Перезаписывать - булево
//		Если контрагент уже существует, то будут обновлены его реквизиты
// Возвращаемое значение: СправочникСсылка.Контрагенты
//
Функция ПолучитьКонтрагента(Данные, Параметры, Перезаписывать = Ложь) Экспорт
	
	СпрСсылка  = Неопределено;
	СтрПаспорт = "";
	
	Попытка
		КонтрагентГУИД = Данные.КонтрагентГУИД;
	Исключение
		КонтрагентГУИД = Неопределено;
	КонецПопытки;	
	
	Если ЗначениеЗаполнено(КонтрагентГУИД) Тогда
		
		СпрСсылка = ПолучитьОбъектПоСоотвествию(КонтрагентГУИД, Параметры.НастройкаКонтрагенты, Параметры.База);
		Если ЗначениеЗаполнено(СпрСсылка) Тогда
			Возврат СпрСсылка;
		КонецЕсли;	
		
	КонецЕсли;		
	
	Если ЗначениеЗаполнено(Данные.КонтрагентИНН) Тогда
		СпрСсылка = НайтиКонтрагента(Данные.Контрагент, Данные.КонтрагентИНН, Данные.КонтрагентКПП);
		ЮридическоеФизическоеЛицо = Перечисления.ЮридическоеФизическоеЛицо.ЮридическоеЛицо;
		Родитель  = Параметры.КонтрагентРодительЮЛ;
	Иначе
		
		ПаспортСерия = СтрЗаменить(Данные.КонтрагентПаспортСерия, " ", "");
		ПаспортНомер = СтрЗаменить(Данные.КонтрагентПаспортНомер, " ", "");
		СтрПаспорт = СокрЛП(ПаспортСерия) + " " + СокрЛП(ПаспортНомер); 
		Если ЗначениеЗаполнено(Данные.КонтрагентПаспортДата) Тогда
			СтрПаспорт = СтрПаспорт + " выдан: "  + Формат(Данные.КонтрагентПаспортДата, "ДФ=dd.MM.yyyy");
		КонецЕсли;
		СтрПаспорт = СокрЛП(СтрПаспорт);
		
		ЮридическоеФизическоеЛицо = Перечисления.ЮридическоеФизическоеЛицо.ФизическоеЛицо;
		Родитель   = Параметры.КонтрагентРодительФЛ;
		
		Запрос = Новый Запрос;
		
		Если ЗначениеЗаполнено(СтрПаспорт) Тогда
			
			Запрос.Параметры.Вставить("Паспорт", СтрПаспорт);
			Запрос.Текст =
			"ВЫБРАТЬ
			|	Спр.Ссылка КАК Ссылка
			|ИЗ
			|	Справочник.Контрагенты КАК Спр
			|ГДЕ
			|	НЕ Спр.ПометкаУдаления
			|	И Спр.ДокументУдостоверяющийЛичность = &Паспорт";
			
			Результат = Запрос.Выполнить();
			Если НЕ Результат.Пустой() Тогда
				СпрСсылка = Результат.Выгрузить()[0][0];
			КонецЕсли;
			
		КонецЕсли;
		
		Если СпрСсылка = Неопределено Тогда
			
			Запрос.Параметры.Вставить("Наименование", Данные.Контрагент);
			Запрос.Параметры.Вставить("Родитель",     Родитель);
			
			Запрос.Текст =
			"ВЫБРАТЬ
			|	Спр.Ссылка КАК Ссылка
			|ИЗ
			|	Справочник.Контрагенты КАК Спр
			|ГДЕ
			|	НЕ Спр.ПометкаУдаления
			|	И Спр.Наименование = &Наименование";
			
			Результат = Запрос.Выполнить();
			Если НЕ Результат.Пустой() Тогда
				СпрСсылка = Результат.Выгрузить()[0][0];
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЕсли;
	
	Если ЗначениеЗаполнено(СпрСсылка) Тогда
		
		Если Перезаписывать Тогда
			СпрОбъект = СпрСсылка.ПолучитьОбъект();
		Иначе
			
			Если ЗначениеЗаполнено(КонтрагентГУИД) Тогда
				Запись = РегистрыСведений.СоответствиеОбъектовТекущейИВнешнихИБ.СоздатьМенеджерЗаписи();
				Запись.ОбъектВнешнейИБ = КонтрагентГУИД;
				Запись.ИспользуемаяИБ  = Параметры.База;
				Запись.НастройкаСоответствия  = Параметры.НастройкаКонтрагенты;
				Запись.ОбъектТекущейИБ = СпрСсылка;
				Запись.Записать();
			КонецЕсли;	
			
			Возврат СпрСсылка;
			
		КонецЕсли;	
		
	Иначе
		СпрОбъект = Справочники.Контрагенты.СоздатьЭлемент();
	КонецЕсли;	
	
	СпрОбъект.Родитель     = Родитель;
	СпрОбъект.Наименование = Данные.Контрагент;
	СпрОбъект.ИНН          = Данные.КонтрагентИНН;
	СпрОбъект.КПП          = Данные.КонтрагентКПП;
	СпрОбъект.ДокументУдостоверяющийЛичность = СтрПаспорт;
	СпрОбъект.ЮридическоеФизическоеЛицо = ЮридическоеФизическоеЛицо;
	СпрОбъект.СтранаРегистрации         = Справочники.СтраныМира.Россия;
	СпрОбъект.Записать();
	
	Если ЗначениеЗаполнено(КонтрагентГУИД) Тогда
		Запись = РегистрыСведений.СоответствиеОбъектовТекущейИВнешнихИБ.СоздатьМенеджерЗаписи();
		Запись.ОбъектВнешнейИБ = КонтрагентГУИД;
		Запись.ИспользуемаяИБ  = Параметры.База;
		Запись.НастройкаСоответствия  = Параметры.НастройкаКонтрагенты;
		Запись.ОбъектТекущейИБ = СпрОбъект.Ссылка;
		Запись.Записать();
	КонецЕсли;
	
	Возврат СпрОбъект.Ссылка;
		
КонецФункции


// Возвращает ссылку на договор контрагента
//
// Параметры:
//	Контрагент    - СправочникСсылка.Контрагенты
//	Организация   - СправочникСсылка.Организации
//	Наименование  - Строка
//	ВидДоговораУХ - ПеречислениеСсылка.ВидыДоговоровКонтрагентовУХ
//	ПолноеСовпадение - Наименование полностью совпадает или только начинается с 
//
// Возвращаемое значение: СправочникСсылка.ДоговорыКонтрагентов
//
Функция НайтиДоговор(Контрагент, Организация, Наименование, ВидДоговораУХ, ПолноеСовпадение = Истина) Экспорт
	
	Запрос = Новый Запрос;
	
	Если ПолноеСовпадение Тогда
		Запрос.Параметры.Вставить("Наименование", Наименование);
	Иначе
		Запрос.Параметры.Вставить("Наименование", Наименование + "%");
	КонецЕсли;	
		
	Запрос.Параметры.Вставить("Контрагент",   Контрагент);
	Запрос.Параметры.Вставить("Организация",  Организация);
	Запрос.Параметры.Вставить("ВидДоговораУХ", ВидДоговораУХ);
	
	Запрос.Текст =
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	Спр.Ссылка КАК Ссылка
	|ИЗ
	|	Справочник.ДоговорыКонтрагентов КАК Спр
	|ГДЕ
	|	Спр.Наименование ПОДОБНО &Наименование
	|	И Спр.Владелец = &Контрагент
	|	И Спр.Организация = &Организация
	|	И Спр.ВидДоговораУХ = &ВидДоговораУХ
	|	И НЕ Спр.ПометкаУдаления
	|
	|УПОРЯДОЧИТЬ ПО
	|	Спр.Дата УБЫВ,
	|	Спр.Ссылка УБЫВ";
	
	Результат = Запрос.Выполнить();
	Если НЕ Результат.Пустой() Тогда
		Возврат Результат.Выгрузить()[0][0];
	Иначе
		Возврат Справочники.ДоговорыКонтрагентов.ПустаяСсылка();
	КонецЕсли;	
		
КонецФункции

// Возвращает ссылку на договор контрагента.
// Если договор контрагента отсутствует, то создается новый
// Для поиска вызывается функция НайтиДоговор или ОсновнойДоговор
//
// Параметры:
//	Данные - Структура
//		Контрагент    - СправочникСсылка.Контрагенты
//		Организация   - СправочникСсылка.Организации	
//		Наименование  - Строка
//		ВидДоговораУХ - ПеречислениеСсылка.ВидыДоговоровКонтрагентовУХ
//		Дата          - Дата
//		ДатаНачала    - Дата
//		СрокДействия  - Дата
//		ЦФО           - Справочник.Организации
//		СтатьяДДС      - Справочник.СтатьиДвиженияДенежныхСредств
//		СтатьяРасходов - Справочник.СтатьиДоходовИРасходов
//	Перезаписывать - булево
//		Если контрагент уже существует, то будут обновлены его реквизиты
//	Основной - булево
//		Поиск основного договора (из регистра основных договоров) или по наименованию
//
// Возвращаемое значение: СправочникСсылка.Контрагенты
//
Функция ПолучитьДоговор(Данные, Перезаписывать, Основной = Ложь, ПолноеСовпадение = Истина) Экспорт
	
	СпрОбъект = Неопределено;
	
	Если Основной Тогда
		СпрСсылка = ОсновнойДоговор(Данные.Контрагент, Данные.Организация, Данные.ВидДоговораУХ);
	Иначе	
		СпрСсылка = НайтиДоговор(Данные.Контрагент, Данные.Организация, Данные.Наименование, Данные.ВидДоговораУХ, ПолноеСовпадение);
	КонецЕсли;	
	
	Если ЗначениеЗаполнено(СпрСсылка) Тогда
		
		Если Перезаписывать Тогда
			СпрОбъект = СпрСсылка.ПолучитьОбъект();
		Иначе	
			Возврат СпрСсылка;
		КонецЕсли;
		
	КонецЕсли;	
	
	Если СпрОбъект = Неопределено Тогда
		СпрОбъект = Справочники.ДоговорыКонтрагентов.СоздатьЭлемент();
	КонецЕсли;

	// Основные свойства
	СпрОбъект.Владелец      = Данные.Контрагент;
	СпрОбъект.Организация   = Данные.Организация;
	СпрОбъект.Наименование  = Данные.Наименование;
	СпрОбъект.ВидДоговораУХ = Данные.ВидДоговораУХ;
	
	// Вычисляемые свойства
	СпрОбъект.Номер         = СпрОбъект.Наименование;
	СпрОбъект.ВидДоговора   = УправлениеДоговорамиУХКлиентСерверПовтИсп.ВидДоговораБП(СпрОбъект.ВидДоговораУХ);
	СпрОбъект.ВидСоглашения = Перечисления.ВидыСоглашений.ДоговорСУсловием;
	СпрОбъект.ВалютаВзаиморасчетов = ОбщегоНазначенияБПВызовСервераПовтИсп.ПолучитьВалютуРегламентированногоУчета();
	
	// Доп. свойства
	Данные.Свойство("Дата",           СпрОбъект.Дата);
	Данные.Свойство("ДатаНачала",     СпрОбъект.ДатаНачала);
	Данные.Свойство("СрокДействия",   СпрОбъект.СрокДействия);
	Данные.Свойство("ЦФО",            СпрОбъект.ОсновнойЦФО);
	Данные.Свойство("СтатьяДДС",      СпрОбъект.ОсновнаяСтатьяДвиженияДенежныхСредств);
	Данные.Свойство("СтатьяДоходов",  СпрОбъект.ОсновнаяСтатьяИсполнение);
	Данные.Свойство("АналитикаБДДС1", СпрОбъект.АналитикаБДДС1);
	Данные.Свойство("АналитикаБДДС2", СпрОбъект.АналитикаБДДС2);
	Данные.Свойство("АналитикаБДДС3", СпрОбъект.АналитикаБДДС3);
	Данные.Свойство("АналитикаИсполнение1", СпрОбъект.АналитикаИсполнение1);
	Данные.Свойство("АналитикаИсполнение2", СпрОбъект.АналитикаИсполнение2);
	Данные.Свойство("АналитикаИсполнение3", СпрОбъект.АналитикаИсполнение3);
	
	Если Данные.Свойство("ДополнительныеРеквизиты") Тогда
		
		Для каждого КлючИЗначение из Данные.ДополнительныеРеквизиты Цикл
			
			СтрокаТЧ = СпрОбъект.ДополнительныеРеквизиты.Найти(КлючИЗначение.Ключ, "Свойство");
			Если СтрокаТЧ = Неопределено Тогда
				СтрокаТЧ = СпрОбъект.ДополнительныеРеквизиты.Добавить();
				СтрокаТЧ.Свойство = КлючИЗначение.Ключ;
			КонецЕсли;
			
			СтрокаТЧ.Значение = КлючИЗначение.Значение;
			
		КонецЦикла;	
		
	КонецЕсли;	
	
	СпрОбъект.Записать();
	
	Если Основной Тогда
		
		Запись = РегистрыСведений.ОсновныеДоговорыКонтрагента.СоздатьМенеджерЗаписи();
		Запись.Организация = Данные.Организация;
		Запись.Контрагент  = Данные.Контрагент;
		Запись.ВидДоговора = СпрОбъект.ВидДоговора;
		Запись.Договор     = СпрОбъект.Ссылка;
		Запись.Записать();
		
	КонецЕсли;	
	
	Возврат СпрОбъект.Ссылка;
		
	
КонецФункции

// Возвращает ссылку на договор контрагента.
//
// Параметры:
//	Контрагент    - СправочникСсылка.Контрагенты
//	Организация   - СправочникСсылка.Организации	
//	ВидДоговораУХ - ПеречислениеСсылка.ВидыДоговоровКонтрагентовУХ
//
// Возвращаемое значение: СправочникСсылка.Контрагенты
//
Функция ОсновнойДоговор(Контрагент, Организация, ВидДоговораУХ) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Параметры.Вставить("Контрагент",    Контрагент);
	Запрос.Параметры.Вставить("Организация",   Организация);
	Запрос.Параметры.Вставить("ВидДоговораУХ", ВидДоговораУХ);
	Запрос.Параметры.Вставить("ВидДоговора",   УправлениеДоговорамиУХКлиентСерверПовтИсп.ВидДоговораБП(ВидДоговораУХ));
	Запрос.Текст =
	"ВЫБРАТЬ
	|	Рег.Договор КАК Договор
	|ИЗ
	|	РегистрСведений.ОсновныеДоговорыКонтрагента КАК Рег
	|ГДЕ
	|	Рег.Организация = &Организация
	|	И Рег.Контрагент = &Контрагент
	|	И Рег.ВидДоговора = &ВидДоговора";
	
	Результат = Запрос.Выполнить();
	Если НЕ Результат.Пустой() Тогда
		Возврат Результат.Выгрузить()[0][0];
	КонецЕсли;
	
	Запрос.Текст =
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	Спр.Ссылка КАК Ссылка
	|ИЗ
	|	Справочник.ДоговорыКонтрагентов КАК Спр
	|ГДЕ
	|	Спр.Владелец = &Контрагент
	|	И Спр.Организация = &Организация
	|	И Спр.ВидДоговораУХ = &ВидДоговораУХ
	|	И НЕ Спр.ПометкаУдаления
	|
	|УПОРЯДОЧИТЬ ПО
	|	Ссылка УБЫВ";
	
	Результат = Запрос.Выполнить();
	Если НЕ Результат.Пустой() Тогда
		Возврат Результат.Выгрузить()[0][0];
	КонецЕсли;
	
КонецФункции	


Функция ПолучитьОбъектПоСоотвествию(Наименование, Настройка, База, Кэш = Неопределено) Экспорт
	
	Если Кэш <> Неопределено Тогда
		
		СпрСсылка = Кэш[Наименование];
		Если СпрСсылка <> Неопределено Тогда
			Возврат СпрСсылка;
		КонецЕсли;
		
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.Параметры.Вставить("Наименование", Наименование);
	Запрос.Параметры.Вставить("База",         База);
	Запрос.Параметры.Вставить("Настройка",    Настройка);
	
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	Рег.ОбъектТекущейИБ КАК ОбъектТекущейИБ
	|ИЗ
	|	РегистрСведений.СоответствиеОбъектовТекущейИВнешнихИБ КАК Рег
	|ГДЕ
	|	Рег.ОбъектВнешнейИБ = &Наименование
	|	И Рег.НастройкаСоответствия = &Настройка
	|	И Рег.ИспользуемаяИБ = &База";
	
	Результат = Запрос.Выполнить();
	Если Результат.Пустой() Тогда
		СпрСсылка = Справочники.Организации.ПустаяСсылка();
	Иначе
		СпрСсылка = Результат.Выгрузить()[0][0];
	КонецЕсли;	
	
	Если Кэш <> Неопределено Тогда
		Кэш.Вставить(Наименование, СпрСсылка);
	КонецЕсли;
	
	Возврат СпрСсылка;
	
КонецФункции

Функция ПолучитьЗначениеВнешнейИБ(Ссылка, Настройка, База) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Параметры.Вставить("Ссылка",    Ссылка);
	Запрос.Параметры.Вставить("Настройка", Настройка);
	Запрос.Параметры.Вставить("База",      База);
	Запрос.Текст =
	"ВЫБРАТЬ
	|	Рег.ОбъектВнешнейИБ КАК ОбъектВнешнейИБ
	|ИЗ
	|	РегистрСведений.СоответствиеОбъектовТекущейИВнешнихИБ КАК Рег
	|ГДЕ
	|	Рег.ОбъектТекущейИБ = &Ссылка
	|	И Рег.НастройкаСоответствия = &Настройка
	|	И Рег.ИспользуемаяИБ = &База";
	
	Результат = Запрос.Выполнить();
	Если Результат.Пустой() Тогда
		Возврат "";
	Иначе
		Возврат Результат.Выгрузить()[0][0];
	КонецЕсли;	
	
КонецФункции

Функция ПолучитьОрганизациюПоИНН(ИНН, КПП, Кэш) Экспорт
	
	Если НЕ ЗначениеЗаполнено(ИНН)
		И НЕ ЗначениеЗаполнено(КПП) Тогда
		
		Возврат Справочники.Организации.ПустаяСсылка();
		
	КонецЕсли;	
	
	СпрСсылка = Кэш[ИНН + "/" + КПП];
	Если СпрСсылка <> Неопределено Тогда
		Возврат СпрСсылка;
	КонецЕсли;	
	
	Запрос = Новый Запрос;
	Запрос.Параметры.Вставить("ИНН", ИНН);
	Запрос.Параметры.Вставить("КПП", КПП);
	
	Если ЗначениеЗаполнено(КПП) Тогда
		
		Запрос.Текст =
		"ВЫБРАТЬ ПЕРВЫЕ 1
		|	Спр.Ссылка КАК Ссылка
		|ИЗ
		|	Справочник.Организации КАК Спр
		|ГДЕ
		|	НЕ Спр.ПометкаУдаления
		|	И Спр.ИНН = &ИНН
		|	И Спр.КПП = &КПП";
		
	Иначе
		
		Запрос.Текст =
		"ВЫБРАТЬ ПЕРВЫЕ 1
		|	Спр.Ссылка КАК Ссылка
		|ИЗ
		|	Справочник.Организации КАК Спр
		|ГДЕ
		|	НЕ Спр.ПометкаУдаления
		|	И Спр.ИНН = &ИНН";
		
	КонецЕсли;
	
	Результат = Запрос.Выполнить();
	Если НЕ Результат.Пустой() Тогда
		СпрСсылка = Результат.Выгрузить()[0][0];
	Иначе	
		СпрСсылка = Справочники.Организации.ПустаяСсылка();
	КонецЕсли;
	
	Кэш.Вставить(ИНН + "/" + КПП, СпрСсылка);
	Возврат СпрСсылка;
	
КонецФункции	

Функция НайтиБанк(БИК) Экспорт
	
	Если НЕ ЗначениеЗаполнено(БИК) Тогда
		Возврат Справочники.Банки.ПустаяСсылка();
	КонецЕсли;	
	
	Запрос = Новый Запрос;
	Запрос.Параметры.Вставить("Код", БИК);
	Запрос.Текст =
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	Спр.Ссылка КАК Ссылка
	|ИЗ
	|	Справочник.Банки КАК Спр
	|ГДЕ
	|	НЕ Спр.ПометкаУдаления
	|	И НЕ Спр.ЭтоГруппа
	|	И Спр.Код = &Код";
	
	Результат = Запрос.Выполнить();
	Если НЕ Результат.Пустой() Тогда
		Возврат Результат.Выгрузить()[0][0];
	Иначе
		Возврат Справочники.Банки.ПустаяСсылка();
	КонецЕсли;	
	
КонецФункции

Функция НайтиДокументПоСвойству(Значение, Свойство, ТипДокумента) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Параметры.Вставить("Значение", Значение); 
	Запрос.Параметры.Вставить("Свойство", Свойство); 
	Запрос.Текст =
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	Рег.Объект КАК Объект
	|ИЗ
	|	РегистрСведений.ДополнительныеСведения КАК Рег 
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.РеализацияТоваровУслуг КАК Док 
	|		ПО Док.Ссылка = Рег.Объект
	|			И НЕ Док.ПометкаУдаления	
	|ГДЕ
	|	Рег.Свойство = &Свойство
	|	И Рег.Значение = &Значение
	|
	|УПОРЯДОЧИТЬ ПО
	|	Док.Дата УБЫВ";
	
	Запрос.Текст = СтрЗаменить(Запрос.Текст, "РеализацияТоваровУслуг", ТипДокумента);	
	
	Результат = Запрос.Выполнить();
	Если НЕ Результат.Пустой() Тогда
		Возврат Результат.Выгрузить()[0][0];
	Иначе
		Возврат Документы[ТипДокумента].ПустаяСсылка();
	КонецЕсли;	
	
КонецФункции

Функция НайтиДокументКорректировки(ДокументРТУ) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Параметры.Вставить("ДокументРеализации", ДокументРТУ);
	Запрос.Текст =
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	Док.Ссылка КАК Ссылка
	|ИЗ
	|	Документ.КорректировкаРеализации КАК Док
	|ГДЕ
	|	Док.ДокументРеализации = &ДокументРеализации
	|	И НЕ Док.ПометкаУдаления
	|
	|УПОРЯДОЧИТЬ ПО
	|	Док.Дата УБЫВ";
	
	Результат = Запрос.Выполнить();
	Если НЕ Результат.Пустой() Тогда
		ДокументСсылка = Результат.Выгрузить()[0][0];
	Иначе
		ДокументСсылка = Документы.КорректировкаРеализации.ПустаяСсылка();
	КонецЕсли;
	
	Возврат ДокументСсылка;
	
КонецФункции	

Функция ПолучитьОсновнуюБазу(Организация, Кэш = Неопределено) Экспорт
	
	Если Кэш <> Неопределено Тогда
		СпрСсылка = Кэш[Организация];
		Если СпрСсылка <> Неопределено Тогда
			Возврат СпрСсылка;
		КонецЕсли;	
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.Параметры.Вставить("Организация", Организация);
	Запрос.Текст =
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	Рег.ЗначениеЭлементаНастройкиОтчета КАК ЗначениеЭлементаНастройкиОтчета
	|ИЗ
	|	РегистрСведений.НастройкаОбработкиОтчетов КАК Рег
	|ГДЕ
	|	Рег.ЭлементНастройкиОтчета = ЗНАЧЕНИЕ(Перечисление.ЭлементыНастройкиОтчета.ВнешняяИнформационнаяБаза)
	|	И Рег.Организация = &Организация
	|	И Рег.ШаблонДокументаБД = НЕОПРЕДЕЛЕНО";
	
	Результат = Запрос.Выполнить();
	Если НЕ Результат.Пустой() Тогда
		СпрСсылка = Результат.Выгрузить()[0][0];
	КонецЕсли;	
	
	Если Кэш <> Неопределено Тогда
		Кэш.Вставить(Организация, СпрСсылка);
	КонецЕсли;
	
	Возврат СпрСсылка;
	
КонецФункции	

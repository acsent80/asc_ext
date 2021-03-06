﻿
&Вместо("ОбновитьОтчет")
Процедура АСЦ1_ОбновитьОтчет(Результат, Объект, СохраненнаяНастройка, ДанныеРасшифровки, ОбщийОтбор, ПараметрыОтчета, URLСхемы, ВнешнийКонтекст, ИмяОтчета, Знач ИспользоватьДанныеРегистра, НастройкиКомпоновщика, ГрафСхема)
		
	Перем СтруктураПараметровДляМонитораЭффективности;
	Перем ЗначенияНастроекПанелиПользователя;
	Перем НастройкиМонитораЭффективности;
	Перем НастройкиПериода;
	
	//Сохраненная настройка передается в виде структуры при отображении отчета - расшифровки, так как настройки отбора зависят от поля расшифровки.
	Если ТипЗнч(СохраненнаяНастройка) = Тип("Структура") Тогда
		СохраненнаяНастройка.Свойство("НастройкиКомпоновщика", НастройкиКомпоновщика);
		СохраненнаяНастройка.Свойство("ЗначенияНастроекПанелиПользователя", ЗначенияНастроекПанелиПользователя);
		ИспользоватьДанныеРегистра = Ложь; // Пришли измененные данные. Использовать сохраненные данные в отчете нельзя.
	//Используются сохраненные настройки.
	ИначеЕсли ЗначениеЗаполнено(СохраненнаяНастройка) Тогда
		ХранилищеНастроек = СохраненнаяНастройка.ХранилищеНастроек.Получить();
		
		Если ХранилищеНастроек = Неопределено Тогда
			
			ОбщегоНазначенияУХ.СообщитьОбОшибке("Не удалось прочитать настройки отчета. Будут использованы настройки по умолчанию");
			ЗначенияНастроекПанелиПользователя = Объект.ЗначенияНастроекПанелиПользователя.Получить();
			НастройкиКомпоновщика = Объект.НастройкиСхемыКомпоновкиДанныхПоУмолчанию.Получить();
		Иначе
			ЗначенияНастроекПанелиПользователя = ХранилищеНастроек.ЗначенияНастроекПанелиОтчета;
			НастройкиКомпоновщика              = ХранилищеНастроек.НастройкиКомпоновки;
		КонецЕсли;
		
	//Используются настройки по умолчанию
	Иначе
		ЗначенияНастроекПанелиПользователя = Объект.ЗначенияНастроекПанелиПользователя.Получить();
		НастройкиКомпоновщика = Объект.НастройкиСхемыКомпоновкиДанныхПоУмолчанию.Получить();
	КонецЕсли;
	
	Если ЗначенияНастроекПанелиПользователя = Неопределено Тогда
		
		ЗначенияНастроекПанелиПользователя = ТиповыеОтчеты_УправляемыйРежимУХ.ПолучитьЗначенияНастроекПанелиПользователяПоУмолчанию(НастройкиКомпоновщика);
		
	КонецЕсли;
	
	КомпоновщикНастроек = Новый КомпоновщикНастроекКомпоновкиДанных;
	
	Если ЗначенияНастроекПанелиПользователя <> Неопределено Тогда
		ЗначенияНастроекПанелиПользователя.Свойство("НастройкиМонитораЭффективности", НастройкиМонитораЭффективности);
		ЗначенияНастроекПанелиПользователя.Свойство("НастройкаПериода", НастройкиПериода);
	КонецЕсли;
	
	Если Объект.ВидПроизвольногоОтчета = 1 Тогда // Монитор ключевых показателей.
		
		ТЗОтвета = БизнесАнализВызовСервераУХ.СформироватьТаблицуМонитораПоказателей(ИмяОтчета);
		Результат = ТЗОтвета; 		// По умолчанию результат - пустое дерево значений, которое вернется в случае ошибки.
		
		ВнешнийКонтекст = ВернутьСтруктуруВнешнегоКонтекста(НастройкиПериода, НастройкиМонитораЭффективности, ОбщийОтбор, ПараметрыОтчета);
		ОтборОрганизация = ОбщегоНазначенияКлиентСервер.СвойствоСтруктуры(ВнешнийКонтекст, "Организация", Справочники.Организации.ПустаяСсылка());
		
		Запрос = Новый Запрос;
		Запрос.МенеджерВременныхТаблиц = Новый МенеджерВременныхТаблиц;
		
		Если ТипЗнч(ПараметрыОтчета) = Тип("Структура") Тогда
			
			Для Каждого ЭлементСтруктуры Из ПараметрыОтчета Цикл
				Если НастройкиМонитораЭффективности.Свойство(ЭлементСтруктуры.Ключ) Тогда
					НастройкиМонитораЭффективности.Вставить(ЭлементСтруктуры.Ключ, ЭлементСтруктуры.Значение);
				КонецЕсли;
			КонецЦикла;
			
		КонецЕсли;
		
		Если ИспользоватьДанныеРегистра Тогда
			Запрос.Текст = 
			"ВЫБРАТЬ
			|	ПроизвольныеОтчетыИсточникиДанных.ИсточникДанных КАК Показатель,
			|	ПоказателиМонитораКлючевыхПоказателей.Проекция КАК Проекция,
			|	ВЫБОР КОГДА ПоказателиМонитораКлючевыхПоказателей.ИсточникЗначенияТекущегоПериода = ЗНАЧЕНИЕ(Справочник.ИсточникиДанныхДляРасчетов.ПустаяСсылка) ТОГДА ЛОЖЬ
			|	ИНАЧЕ ИСТИНА КОНЕЦ КАК ИспользуетсяФактическоеЗначениеТекущегоПериода,
			|	ВЫБОР КОГДА ПоказателиМонитораКлючевыхПоказателей.ИсточникЗначенияПериодаСравнения = ЗНАЧЕНИЕ(Справочник.ИсточникиДанныхДляРасчетов.ПустаяСсылка) ТОГДА ЛОЖЬ
			|	ИНАЧЕ ИСТИНА КОНЕЦ КАК ИспользуетсяФактическоеЗначениеПредыдущегоПериода,
			|	ВЫБОР КОГДА ПоказателиМонитораКлючевыхПоказателей.ИсточникПлановогоЗначения = ЗНАЧЕНИЕ(Справочник.ИсточникиДанныхДляРасчетов.ПустаяСсылка) ТОГДА ЛОЖЬ
			|	ИНАЧЕ ИСТИНА КОНЕЦ КАК ИспользуетсяПлановоеЗначение,
			|	ЕСТЬNULL(ЦелиКлючевыеПоказатели.Ссылка, ЗНАЧЕНИЕ(Справочник.Цели.ПустаяСсылка)) КАК Цель,
			|	ПроизвольныеОтчетыИсточникиДанных.ВнешняяИБ КАК ВнешняяИБ,
			|	ЗначенияПоказателейМКП.ФактическоеЗначениеТекущегоПериода,
			|	ЗначенияПоказателейМКП.ФактическоеЗначениеПредыдущегоПериода,
			|	ЗначенияПоказателейМКП.ПлановоеЗначение,
			|	ЗначенияПоказателейМКП.Состояние,
			|	ЗначенияПоказателейМКП.Тренд,
			|	ЗначенияПоказателейМКП.Ответственный,
			|	ЗначенияПоказателейМКП.ИзменениеАбсолютное,
			|	ЗначенияПоказателейМКП.ИзменениеОтносительное,
			|	ЗначенияПоказателейМКП.ОтклонениеОтПланаАбсолютное,
			|	ЗначенияПоказателейМКП.ОтклонениеОтПланаОтносительное,
			|	ЗначенияПоказателейМКП.ПроцентВыполненияПлана
			|ПОМЕСТИТЬ ВН_Таблица
			|ИЗ
			|	Справочник.ПроизвольныеОтчеты.ИсточникиДанных КАК ПроизвольныеОтчетыИсточникиДанных
			|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.ПроизвольныеОтчеты КАК ПроизвольныеОтчеты
			|		ПО ПроизвольныеОтчетыИсточникиДанных.Ссылка = ПроизвольныеОтчеты.Ссылка
			|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.ПоказателиМонитораКлючевыхПоказателей КАК ПоказателиМонитораКлючевыхПоказателей
			|			ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ЗначенияПоказателейМКП КАК ЗначенияПоказателейМКП
			|			ПО (ЗначенияПоказателейМКП.МКП = &ПроизвольныйОтчет)
			|				И (ЗначенияПоказателейМКП.Показатель = ПоказателиМонитораКлючевыхПоказателей.Ссылка)
			|				И (ЗначенияПоказателейМКП.СохраненнаяНастройка = &СохраненнаяНастройка)
			|		ПО ПроизвольныеОтчетыИсточникиДанных.ИсточникДанных = ПоказателиМонитораКлючевыхПоказателей.Ссылка
			|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Цели.КлючевыеПоказатели КАК ЦелиКлючевыеПоказатели
			|		ПО (ЦелиКлючевыеПоказатели.Показатель = ПоказателиМонитораКлючевыхПоказателей.Ссылка)
			|ГДЕ
			|	ПроизвольныеОтчеты.Ссылка = &ПроизвольныйОтчет";
			
			Запрос.УстановитьПараметр("ПроизвольныйОтчет", Объект.Ссылка);
			Запрос.УстановитьПараметр("СохраненнаяНастройка", СохраненнаяНастройка);
			
		Иначе
			Запрос.Текст = 
			"ВЫБРАТЬ
			|	ПроизвольныеОтчетыИсточникиДанных.ИсточникДанных КАК Показатель,
			|	ПоказателиМонитораКлючевыхПоказателей.Проекция КАК Проекция,
			|	ЕСТЬNULL(ЦелиКлючевыеПоказатели.Ссылка, ЗНАЧЕНИЕ(Справочник.Цели.ПустаяСсылка)) КАК Цель,
			|	ЕСТЬNULL(ВЫБОР
			|			КОГДА ПоказателиМонитораКлючевыхПоказателей.Ответственный ССЫЛКА Справочник.Пользователи
			|				ТОГДА ПоказателиМонитораКлючевыхПоказателей.Ответственный
			|			ИНАЧЕ ОтветственныеПоПоказателю.Пользователь
			|		КОНЕЦ, ЗНАЧЕНИЕ(Справочник.Пользователи.ПустаяСсылка)) КАК Ответственный,
			|	ПроизвольныеОтчетыИсточникиДанных.ВнешняяИБ КАК ВнешняяИБ
			|ПОМЕСТИТЬ ВН_Таблица
			|ИЗ
			|	Справочник.ПроизвольныеОтчеты.ИсточникиДанных КАК ПроизвольныеОтчетыИсточникиДанных
			|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.ПроизвольныеОтчеты КАК ПроизвольныеОтчеты
			|		ПО ПроизвольныеОтчетыИсточникиДанных.Ссылка = ПроизвольныеОтчеты.Ссылка
			|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.ПоказателиМонитораКлючевыхПоказателей КАК ПоказателиМонитораКлючевыхПоказателей
			|			ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ОтветственныеОрганизаций КАК ОтветственныеПоПоказателю
			|			ПО (ОтветственныеПоПоказателю.Организация = &ОтборОрганизация)
			|				И (ОтветственныеПоПоказателю.Роль = ПоказателиМонитораКлючевыхПоказателей.Ответственный)
			|		ПО ПроизвольныеОтчетыИсточникиДанных.ИсточникДанных = ПоказателиМонитораКлючевыхПоказателей.Ссылка
			|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Цели.КлючевыеПоказатели КАК ЦелиКлючевыеПоказатели
			|		ПО (ЦелиКлючевыеПоказатели.Показатель = ПоказателиМонитораКлючевыхПоказателей.Ссылка)
			|ГДЕ
			|	ПроизвольныеОтчеты.Ссылка = &ПроизвольныйОтчет";
			ЗАпрос.УстановитьПараметр("ОтборОрганизация", ОтборОрганизация);
			Запрос.УстановитьПараметр("ПроизвольныйОтчет", Объект.Ссылка);
		КонецЕсли;
		Запрос.Выполнить();
		
		Если ИспользоватьДанныеРегистра Тогда
			Запрос.Текст = "
			|ВЫБРАТЬ
			|	Вн_Таблица.Показатель,
			|	Вн_Таблица.Ответственный,
			|	Вн_Таблица.Проекция,
			|	Вн_Таблица.Цель,
			|	Вн_Таблица.ВнешняяИБ,
			|	Вн_Таблица.ФактическоеЗначениеТекущегоПериода,
			|	Вн_Таблица.ФактическоеЗначениеПредыдущегоПериода,
			|	Вн_Таблица.ПлановоеЗначение,
			|	Вн_Таблица.ИзменениеАбсолютное,
			|	Вн_Таблица.ИзменениеОтносительное,
			|	Вн_Таблица.ОтклонениеОтПланаАбсолютное,
			|	Вн_Таблица.ОтклонениеОтПланаОтносительное,
			|	Вн_Таблица.ПроцентВыполненияПлана,
			|	Вн_Таблица.Тренд,
			|	Вн_Таблица.Состояние,
			|	Вн_Таблица.ИспользуетсяФактическоеЗначениеТекущегоПериода,
			|	Вн_Таблица.ИспользуетсяФактическоеЗначениеПредыдущегоПериода,
			|	Вн_Таблица.ИспользуетсяПлановоеЗначение,
			|	ЛОЖЬ КАК Обработано
			|ИЗ
			|	ВН_Таблица КАК Вн_Таблица
			|
			|УПОРЯДОЧИТЬ ПО
			|	Вн_Таблица.Проекция,
			|	Вн_Таблица.Ответственный,
			|	Вн_Таблица.Цель";
		Иначе
			Запрос.Текст = "
			|ВЫБРАТЬ
			|	Вн_Таблица.Показатель,
			|	Вн_Таблица.Ответственный,
			|	Вн_Таблица.Проекция,
			|	Вн_Таблица.Цель,
			|	Вн_Таблица.ВнешняяИБ,
			|	ЛОЖЬ КАК Обработано
			|ИЗ
			|	ВН_Таблица КАК Вн_Таблица
			|
			|УПОРЯДОЧИТЬ ПО
			|	Вн_Таблица.Проекция,
			|	Вн_Таблица.Ответственный,
			|	Вн_Таблица.Цель";
		КонецЕсли;
		
		Если Объект.ГруппировкаМонитора = 0 Тогда // Группировка не используется. Вывод данных напрямую из таблицы показателей
			
			Если Объект.ОтображатьЦели Тогда
				
				Если ИспользоватьДанныеРегистра Тогда
					ТаблицаПоказателей = Запрос.Выполнить().Выгрузить();
				Иначе
					ТаблицаПоказателей = ПолучитьТаблицуЗначенийПоказателейМКП(Объект.Ссылка, ВнешнийКонтекст, , Истина);
					Если ТаблицаПоказателей = Неопределено Тогда
						Результат = ТЗОтвета;
						Возврат;
					КонецЕсли;
				КонецЕсли;
				
				ТаблицаСвязей      = Новый ТаблицаЗначений;
				ТаблицаЭлементов   = Новый ТаблицаЗначений;
				ЗаполнитьТаблицуСвязейИЭлементов(ТаблицаСвязей, ТаблицаЭлементов, ТаблицаПоказателей, 3, ОтборОрганизация);
				ЭлементыПервогоУровня = ТаблицаЭлементов.Скопировать(Новый Структура("ЭлементВерхнегоУровня", Истина));
				
				
				
				Для Каждого Элемент Из ЭлементыПервогоУровня Цикл
					
					СтрокаЦели = ТЗОтвета.Строки.Добавить();
					СтрокаЦели[ИмяОтчета + "Показатель"] = Элемент.Элемент;
					СтрокаЦели[ИмяОтчета + "Ответственный"] = Элемент.Ответственный;
					ВидСтроки = ?(ТипЗнч(Элемент.Элемент) = Тип("СправочникСсылка.ПоказателиМонитораКлючевыхПоказателей"), 0, 1);
					СтрокаЦели[ИмяОтчета + "СлужебнаяСтрока"] = ВидСтроки;
					Состояние = ЗаполнитьПодчиненныеСтрокиДерева(ТаблицаСвязей, СтрокаЦели, ТаблицаПоказателей, ТаблицаЭлементов, ИмяОтчета, НастройкиМонитораЭффективности);
					Если ВидСтроки = 1 Тогда
						СтрокаЦели[ИмяОтчета + "Состояние"] = ТиповыеОтчетыУХ.ВернутьКодПредставленияТренда(Состояние);
					КонецЕсли;
					
				КонецЦикла;
				
				СоответствиеЦелей = СформироватьСоответствиеКоличестваИнициативЦелям();
				ТабУзловСхема = ПреобразоватьТабУзлов(ТаблицаЭлементов, ТЗОтвета, ИмяОтчета, СоответствиеЦелей);
				ТабСвязейСхема = ПреобразоватьТабСвязей(ТаблицаСвязей);
				ЗаполнитьИсточникУзлов(ТабУзловСхема, ТабСвязейСхема);
				Если ГрафСхема <> Неопределено Тогда
					МассивУзлов = ТабУзловСхема.ВыгрузитьКолонку("Узел");
					ТаблицаИнвестирования = ПолучитьТаблицуИнвестированияГрафическойСхемы(ТаблицаСвязей);
					СоответстветствиеУчастия = РасчетДолейВладения.ПолучитьПоследовательностиУчастия(МассивУзлов, ТаблицаИнвестирования);
					РасчетДолейВладения.ЗаполнитьСтрокиКакМаксимальнаяПоследовательностьОбъектаИнвестирования(ТабУзловСхема, СоответстветствиеУчастия);
					ПредставлениеСвязи = Новый Массив;
					ПредставлениеСвязи.Добавить("Представление");
					РасчетДолейВладения.РасположитьУзлыИСвязи(ТабУзловСхема, ТабСвязейСхема, ПредставлениеСвязи);
					ТабУзловСхема = ПереставитьКолонкиУзловСхемы(ТабУзловСхема, ТабСвязейСхема);
					ГрафСхема = ОтрисовкаГрафа.ПолучитьГрафическуюСхемуГрафа(ТабСвязейСхема, ТабУзловСхема, , 1.5);
				Иначе
					ГрафСхема = Новый ГрафическаяСхема;
				КонецЕсли;
			Иначе
				
				Если ИспользоватьДанныеРегистра Тогда
					Выборка = Запрос.Выполнить().Выбрать();
					Пока Выборка.Следующий() Цикл
						
						СтрокаПоказателя = ТЗОтвета.Строки.Добавить();
						СтрокаПоказателя[ИмяОтчета + "Показатель"]                            = Выборка.Показатель;
						СтрокаПоказателя[ИмяОтчета + "ИспользуемаяИБ"]                        = Выборка.ВнешняяИБ;
						СтрокаПоказателя[ИмяОтчета + "Ответственный"]                         = Выборка.Ответственный;
						СтрокаПоказателя[ИмяОтчета + "Тренд"]                                 = ТиповыеОтчетыУХ.ВернутьКодПредставленияТренда(Выборка.Тренд);
						СтрокаПоказателя[ИмяОтчета + "Состояние"]                             = ТиповыеОтчетыУХ.ВернутьКодПредставленияТренда(Выборка.Состояние);
						СтрокаПоказателя[ИмяОтчета + "ФактическоеЗначениеТекущегоПериода"]    = Выборка.ФактическоеЗначениеТекущегоПериода;
						СтрокаПоказателя[ИмяОтчета + "ФактическоеЗначениеПредыдущегоПериода"] = Выборка.ФактическоеЗначениеПредыдущегоПериода;
						СтрокаПоказателя[ИмяОтчета + "ПлановоеЗначение"]                      = Выборка.ПлановоеЗначение;
						СтрокаПоказателя[ИмяОтчета + "ИзменениеАбсолютное"]                   = Выборка.ИзменениеАбсолютное;
						СтрокаПоказателя[ИмяОтчета + "ИзменениеОтносительное"]                = Выборка.ИзменениеОтносительное;
						СтрокаПоказателя[ИмяОтчета + "ОтклонениеОтПланаАбсолютное"]           = Выборка.ОтклонениеОтПланаАбсолютное;
						СтрокаПоказателя[ИмяОтчета + "ОтклонениеОтПланаОтносительное"]        = Выборка.ОтклонениеОтПланаОтносительное;
						СтрокаПоказателя[ИмяОтчета + "ПроцентВыполненияПлана"]                 = Выборка.ПроцентВыполненияПлана;
						
						СтрокаПоказателя[ИмяОтчета + "ИспользуетсяФактическоеЗначениеТекущегоПериода"]    = Выборка.ИспользуетсяФактическоеЗначениеТекущегоПериода;
						СтрокаПоказателя[ИмяОтчета + "ИспользуетсяФактическоеЗначениеПредыдущегоПериода"] = Выборка.ИспользуетсяФактическоеЗначениеПредыдущегоПериода;
						СтрокаПоказателя[ИмяОтчета + "ИспользуетсяПлановоеЗначение"]                      = Выборка.ИспользуетсяПлановоеЗначение;
						
					КонецЦикла;
				Иначе
					ТаблицаПоказателей = ПолучитьТаблицуЗначенийПоказателейМКП(Объект.Ссылка, ВнешнийКонтекст, , Истина);
					Если ТаблицаПоказателей <> Неопределено Тогда
						Для Каждого Строка Из ТаблицаПоказателей Цикл
							СтрокаПоказателя = ТЗОтвета.Строки.ДОбавить();
							СтрокаПоказателя[ИмяОтчета + "Показатель"]                            = Строка.Показатель;
							СтрокаПоказателя[ИмяОтчета + "ИспользуемаяИБ"]                        = Строка.ВнешняяИБ;
							СтрокаПоказателя[ИмяОтчета + "Ответственный"]                         = Строка.Ответственный;
							СтрокаПоказателя[ИмяОтчета + "Тренд"]                                 = ТиповыеОтчетыУХ.ВернутьКодПредставленияТренда(Строка.Тренд);
							СтрокаПоказателя[ИмяОтчета + "Состояние"]                             = ТиповыеОтчетыУХ.ВернутьКодПредставленияТренда(Строка.Состояние);
							СтрокаПоказателя[ИмяОтчета + "ФактическоеЗначениеТекущегоПериода"]    = Строка.ФактическоеЗначениеТекущегоПериода;
							СтрокаПоказателя[ИмяОтчета + "ФактическоеЗначениеПредыдущегоПериода"] = Строка.ФактическоеЗначениеПредыдущегоПериода;
							СтрокаПоказателя[ИмяОтчета + "ПлановоеЗначение"]                      = Строка.ПлановоеЗначение;
							СтрокаПоказателя[ИмяОтчета + "ИзменениеАбсолютное"]                   = Строка.ИзменениеАбсолютное;
							СтрокаПоказателя[ИмяОтчета + "ИзменениеОтносительное"]                = Строка.ИзменениеОтносительное;
							СтрокаПоказателя[ИмяОтчета + "ОтклонениеОтПланаАбсолютное"]           = Строка.ОтклонениеОтПланаАбсолютное;
							СтрокаПоказателя[ИмяОтчета + "ОтклонениеОтПланаОтносительное"]        = Строка.ОтклонениеОтПланаОтносительное;
							СтрокаПоказателя[ИмяОтчета + "ПроцентВыполненияПлана"]                 = Строка.ПроцентВыполненияПлана;
							
							СтрокаПоказателя[ИмяОтчета + "ИспользуетсяФактическоеЗначениеТекущегоПериода"]    = ЗначениеЗаполнено(Строка.ИсточникЗначенияТекущегоПериода);
							СтрокаПоказателя[ИмяОтчета + "ИспользуетсяФактическоеЗначениеПредыдущегоПериода"] = ЗначениеЗаполнено(Строка.ИсточникЗначенияПериодаСравнения);
							СтрокаПоказателя[ИмяОтчета + "ИспользуетсяПлановоеЗначение"]                      = ЗначениеЗаполнено(Строка.ИсточникПлановогоЗначения);
							Строка.Обработано = Истина;
						КонецЦикла;
					КонецЕсли;
				КонецЕсли;
			КонецЕсли;
			
		ИначеЕсли Объект.ГруппировкаМонитора = 1 Тогда // Группировка по ответственному
			
			Если ИспользоватьДанныеРегистра Тогда
				ТаблицаПоказателей = Запрос.Выполнить().Выгрузить();
			Иначе
				ТаблицаПоказателей = ПолучитьТаблицуЗначенийПоказателейМКП(Объект.Ссылка, ВнешнийКонтекст, Истина);
				Если ТаблицаПоказателей = Неопределено Тогда
					Результат = ТЗОтвета;
					Возврат;
				КонецЕсли;
			КонецЕсли;
			
			СоответствиеСтрокИПроекций = Новый Соответствие;
			
			Если Объект.ОтображатьЦели Тогда // Если отображаются цели, тогда группировка по ответственным по целям, иначе по показателям.
				ТаблицаСвязей      = Новый ТаблицаЗначений;
				ТаблицаЭлементов   = Новый ТаблицаЗначений;
				ЗаполнитьТаблицуСвязейИЭлементов(ТаблицаСвязей, ТаблицаЭлементов, ТаблицаПоказателей, 3, ОтборОрганизация);
				ТаблицаСтрокПервогоУровня    = ТаблицаЭлементов.Скопировать(Новый Структура("ЭлементВерхнегоУровня", Истина));
				
				Для Каждого Элемент Из ТаблицаСтрокПервогоУровня Цикл
					
					Если СоответствиеСтрокИПроекций[Элемент.Ответственный] = Неопределено Тогда
						
						НоваяСтрока = ТЗОтвета.Строки.Добавить();
						НоваяСтрока[ИмяОтчета + "Ответственный"] = Элемент.Ответственный;
						НоваяСтрока[ИмяОтчета + "СлужебнаяСтрока"] = 2;
						СоответствиеСтрокИПроекций.Вставить(Элемент.Ответственный, НоваяСтрока);
						
					КонецЕсли;
					
					СтрокаЦели = СоответствиеСтрокИПроекций[Элемент.Ответственный].Строки.Добавить();
					СтрокаЦели[ИмяОтчета + "Показатель"] = Элемент.Элемент;
					СтрокаЦели[ИмяОтчета + "Ответственный"] = Элемент.Ответственный;
					ВидСтроки = ?(ТипЗнч(Элемент.Элемент) = Тип("СправочникСсылка.ПоказателиМонитораКлючевыхПоказателей") ,0, 1);
					СтрокаЦели[ИмяОтчета + "СлужебнаяСтрока"] = ВидСтроки;
					Состояние = ЗаполнитьПодчиненныеСтрокиДерева(ТаблицаСвязей, СтрокаЦели, ТаблицаПоказателей, ТаблицаЭлементов, ИмяОтчета, НастройкиМонитораЭффективности);
					Если ВидСтроки = 1 Тогда
						СтрокаЦели[ИмяОтчета + "Состояние"] = ТиповыеОтчетыУХ.ВернутьКодПредставленияТренда(Состояние);
					КонецЕсли;
					
				КонецЦикла;
				
			Иначе
				
				Запрос.Текст = 
				"ВЫБРАТЬ РАЗЛИЧНЫЕ Вн_Таблица.Ответственный КАК ЭлементПервогоУровня ИЗ Вн_Таблица КАК Вн_Таблица";
				
				Выборка = Запрос.Выполнить().Выбрать();
				Пока Выборка.Следующий() Цикл
					НоваяСтрока = ТзОтвета.Строки.Добавить();
					НоваяСтрока[ИмяОтчета + "Ответственный"] = Выборка.ЭлементПервогоУровня;
					НоваяСтрока[ИмяОтчета + "СлужебнаяСтрока"] = Истина;
					СоответствиеСтрокИПроекций.Вставить(Выборка.ЭлементПервогоУровня, НоваяСтрока);
				КонецЦикла;
				
			КонецЕсли;
			
			
		ИначеЕсли Объект.ГруппировкаМонитора = 2 Тогда // Группировка по проекции
			
			Если ИспользоватьДанныеРегистра Тогда
				ТаблицаПоказателей = Запрос.Выполнить().Выгрузить();
			Иначе
				ТаблицаПоказателей = ПолучитьТаблицуЗначенийПоказателейМКП(Объект.Ссылка, ВнешнийКонтекст, , Истина);
				Если ТаблицаПоказателей = Неопределено Тогда
					Результат = ТЗОтвета;
					Возврат;
				КонецЕсли;
			КонецЕсли;
			
			СоответствиеСтрокИПроекций = Новый Соответствие;
			
			Если Объект.ОтображатьЦели Тогда
				
				ТаблицаСвязей      = Новый ТаблицаЗначений;
				ТаблицаЭлементов   = Новый ТаблицаЗначений;
				ЗаполнитьТаблицуСвязейИЭлементов(ТаблицаСвязей, ТаблицаЭлементов, ТаблицаПоказателей, 3, ОтборОрганизация);
				ТаблицаСтрокПервогоУровня    = ТаблицаЭлементов.Скопировать(Новый Структура("ЭлементВерхнегоУровня", Истина));
				
				Для Каждого Элемент Из ТаблицаСтрокПервогоУровня Цикл
					
					Если СоответствиеСтрокИПроекций[Элемент.Проекция] = Неопределено Тогда
						
						НоваяСтрока = ТЗОтвета.Строки.Добавить();
						НоваяСтрока[ИмяОтчета + "Показатель"] = Элемент.Проекция;
						НоваяСтрока[ИмяОтчета + "СлужебнаяСтрока"] = 2;
						СоответствиеСтрокИПроекций.Вставить(Элемент.Проекция, НоваяСтрока);
						
					КонецЕсли;
					
					СтрокаЦели = СоответствиеСтрокИПроекций[Элемент.Проекция].Строки.Добавить();
					СтрокаЦели[ИмяОтчета + "Показатель"] = Элемент.Элемент;
					СтрокаЦели[ИмяОтчета + "Ответственный"] = Элемент.Ответственный;
					ВидСтроки = ?(ТипЗнч(Элемент.Элемент) = Тип("СправочникСсылка.ПоказателиМонитораКлючевыхПоказателей"), 0, 1);
					СтрокаЦели[ИмяОтчета + "СлужебнаяСтрока"] = ВидСтроки;
					Состояние = ЗаполнитьПодчиненныеСтрокиДерева(ТаблицаСвязей, СтрокаЦели, ТаблицаПоказателей, ТаблицаЭлементов, ИмяОтчета, НастройкиМонитораЭффективности);
					Если ВидСтроки = 1 Тогда
						СтрокаЦели[ИмяОтчета + "Состояние"] = ТиповыеОтчетыУХ.ВернутьКодПредставленияТренда(Состояние);
					КонецЕсли;
					
				КонецЦикла;
				
			Иначе
				
				Запрос.Текст = 
				"ВЫБРАТЬ РАЗЛИЧНЫЕ Вн_Таблица.Проекция КАК ЭлементПервогоУровня ИЗ ВН_Таблица КАК ВН_Таблица";
				Выборка = Запрос.Выполнить().Выбрать();
				
				Пока Выборка.Следующий() Цикл
					НоваяСтрока = ТзОтвета.Строки.Добавить();
					НоваяСтрока[ИмяОтчета + "Показатель"] = Выборка.ЭлементПервогоУровня;
					НоваяСтрока[ИмяОтчета + "СлужебнаяСтрока"] = Истина;
					СоответствиеСтрокИПроекций.Вставить(Выборка.ЭлементПервогоУровня, НоваяСтрока);
				КонецЦикла;
				
			КонецЕсли;
			
		КонецЕсли;
		
		Запрос.Текст = 
		"УНИЧТОЖИТЬ Вн_Таблица";
		Запрос.Выполнить();
		
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ТаблицаПоказателей) Тогда
		НеобработанныеПоказатели = ТаблицаПоказателей.НайтиСтроки(Новый Структура("Обработано", Ложь));
		
		Для Каждого Элемент Из НеобработанныеПоказатели Цикл
			
			Если Объект.ГруппировкаМонитора = 1 Тогда
				ПолеГруппировки = Элемент.Ответственный;
			ИначеЕсли Объект.ГруппировкаМонитора = 2 Тогда
				ПолеГруппировки = Элемент.Проекция;
			Иначе
				ПолеГруппировки = Неопределено;
			КонецЕсли;
			
			Если НЕ ЗначениеЗаполнено(ПолеГруппировки) Тогда
				НоваяСтрока = ТЗОтвета; // Нет группировок, строки добавляем непосредственно в таблицу.
			ИначеЕсли СоответствиеСтрокИПроекций[ПолеГруппировки] = Неопределено Тогда
				НоваяСтрока                 = ТзОтвета.Строки.Добавить();
				Если Объект.ГруппировкаМонитора = 1 Тогда
					НоваяСтрока[ИмяОтчета + "Ответственный"] = ПолеГруппировки;
				Иначе
					НоваяСтрока[ИмяОтчета + "Показатель"]    = ПолеГруппировки;
				КонецЕсли;
				НоваяСтрока[ИмяОтчета + "СлужебнаяСтрока"] = 2;
				СоответствиеСтрокИПроекций.Вставить(Элемент.Проекция, НоваяСтрока);
			Иначе
				НоваяСтрока = СоответствиеСтрокИПроекций[ПолеГруппировки];
			КонецЕсли;
			
			Если СостояниеИТрендУдовлетворяетУсловиям(Элемент.Тренд, НастройкиМонитораЭффективности)
				И СостояниеИТрендУдовлетворяетУсловиям(Элемент.Состояние, НастройкиМонитораЭффективности) Тогда
				СтрокаПоказателя = НоваяСтрока.Строки.Добавить();
				СтрокаПоказателя[ИмяОтчета + "Показатель"]                            = Элемент.Показатель;
				СтрокаПоказателя[ИмяОтчета + "ИспользуемаяИБ"]                        = Элемент.ВнешняяИБ;
				СтрокаПоказателя[ИмяОтчета + "Ответственный"]                         = Элемент.Ответственный;
				СтрокаПоказателя[ИмяОтчета + "Тренд"]                                 = ТиповыеОтчетыУХ.ВернутьКодПредставленияТренда(Элемент.Тренд);
				СтрокаПоказателя[ИмяОтчета + "Состояние"]                             = ТиповыеОтчетыУХ.ВернутьКодПредставленияТренда(Элемент.Состояние);
				СтрокаПоказателя[ИмяОтчета + "ФактическоеЗначениеТекущегоПериода"]    = Элемент.ФактическоеЗначениеТекущегоПериода;
				СтрокаПоказателя[ИмяОтчета + "ФактическоеЗначениеПредыдущегоПериода"] = Элемент.ФактическоеЗначениеПредыдущегоПериода;
				СтрокаПоказателя[ИмяОтчета + "ПлановоеЗначение"]                      = Элемент.ПлановоеЗначение;
				СтрокаПоказателя[ИмяОтчета + "ИзменениеАбсолютное"]                   = Элемент.ИзменениеАбсолютное;
				СтрокаПоказателя[ИмяОтчета + "ИзменениеОтносительное"]                = Элемент.ИзменениеОтносительное;
				СтрокаПоказателя[ИмяОтчета + "ОтклонениеОтПланаОтносительное"]        = Элемент.ОтклонениеОтПланаОтносительное;
				СтрокаПоказателя[ИмяОтчета + "ОтклонениеОтПланаАбсолютное"]           = Элемент.ОтклонениеОтПланаАбсолютное;
				СтрокаПоказателя[ИмяОтчета + "ПроцентВыполненияПлана"]                = Элемент.ПроцентВыполненияПлана;
				
				Если ИспользоватьДанныеРегистра Тогда
					СтрокаПоказателя[ИмяОтчета + "ИспользуетсяФактическоеЗначениеТекущегоПериода"]    = Элемент.ИспользуетсяФактическоеЗначениеТекущегоПериода;
					СтрокаПоказателя[ИмяОтчета + "ИспользуетсяФактическоеЗначениеПредыдущегоПериода"] = Элемент.ИспользуетсяФактическоеЗначениеПредыдущегоПериода;
					СтрокаПоказателя[ИмяОтчета + "ИспользуетсяПлановоеЗначение"]                      = Элемент.ИспользуетсяПлановоеЗначение;
				Иначе
					СтрокаПоказателя[ИмяОтчета + "ИспользуетсяФактическоеЗначениеТекущегоПериода"]    = ЗначениеЗаполнено(Элемент.ИсточникЗначенияТекущегоПериода);
					СтрокаПоказателя[ИмяОтчета + "ИспользуетсяФактическоеЗначениеПредыдущегоПериода"] = ЗначениеЗаполнено(Элемент.ИсточникЗначенияПериодаСравнения);
					СтрокаПоказателя[ИмяОтчета + "ИспользуетсяПлановоеЗначение"]                      = ЗначениеЗаполнено(Элемент.ИсточникПлановогоЗначения);
				КонецЕсли;
			КонецЕсли;
			
		КонецЦикла;
		
	КонецЕсли;
	
	// Создадим и инициализируем процессор компоновки
	// Обычный аналитический отчет.
	Если Объект.ВидПроизвольногоОтчета = 0 Тогда
		
		УникальныйИдентификатор = Новый УникальныйИдентификатор;
		URLСхемы = ТиповыеОтчетыУХ.СформироватьСхемуКомпоновкиДанных(Объект, УникальныйИдентификатор);
		КомпоновщикНастроек.Инициализировать(Новый ИсточникДоступныхНастроекКомпоновкиДанных(URLСхемы));
		СхемаОтчета = СериализаторXDTO.ПрочитатьXDTO(СериализаторXDTO.ЗаписатьXDTO(ПолучитьИзВременногоХранилища(URLСхемы)));
		НастройкиИзОбъекта = Объект.НастройкиСхемыКомпоновкиДанныхПоУмолчанию.Получить();
		Если НастройкиИзОбъекта = Неопределено Тогда
			ТекстСообщения = НСтр("ru = 'Не удалось получить настройки компоновки из объекта отчета %Объект%'");
			ТекстСообщения = СтрЗаменить(ТекстСообщения, "%Объект%", Строка(Объект));
			ОбщегоНазначенияУХ.СообщитьОбОшибке(ТекстСообщения);
			Возврат;
		Иначе
			// Выполняем далее.
		КонецЕсли;
		КомпоновщикНастроек.ЗагрузитьНастройки(НастройкиИзОбъекта);
		
		 //АСЦ Ситников++
		КомпоновщикНастроек.ЗагрузитьНастройки(НастройкиКомпоновщика);
		//СкопироватьНастройкиКомпоновщика(КомпоновщикНастроек.Настройки, НастройкиКомпоновщика);
		//АСЦ Ситников--
		
		ТиповыеОтчеты_УправляемыйРежимУХ.ДоработатьТиповойОтчетПередВыводом(Объект, КомпоновщикНастроек);
		АналитическиеОтчетыУХ.ДоработатьАналитическийОтчетПередВыводом(Объект, КомпоновщикНастроек, СхемаОтчета);
		
		Настройки = КомпоновщикНастроек.ПолучитьНастройки();
		
		РабочийКомпоновщикНастроек = Новый КомпоновщикНастроекКомпоновкиДанных;
		РабочийКомпоновщикНастроек.Инициализировать(Новый ИсточникДоступныхНастроекКомпоновкиДанных(URLСхемы));
		РабочийКомпоновщикНастроек.ЗагрузитьНастройки(Настройки);
		
		// Установим отбор по периоду отчета.
		Если ТипЗнч(НастройкиПериода) = Тип("Структура") И НЕ НастройкиПериода.ПериодОтчета.Пустая() Тогда
			
			НайденноеПоле = РабочийКомпоновщикНастроек.Настройки.Отбор.ДоступныеПоляОтбора.НайтиПоле(Новый ПолеКомпоновкиДанных("ПериодОтчета"));
			Если НайденноеПоле <> Неопределено Тогда
				
				ТиповыеОтчетыУХ.ДобавитьОтбор(РабочийКомпоновщикНастроек, НайденноеПоле.Поле, НастройкиПериода.ПериодОтчета);
				
			КонецЕсли;
			
		КонецЕсли;
		
		Если ОбщийОтбор <> Неопределено Тогда
			
			// Для обычного аналитического отчета перенесем общие отборы в настройки СКД.
			Если Объект.ВидПроизвольногоОтчета = 0 Тогда
				Для Каждого ЭлементОтбора Из ОбщийОтбор.Отбор.Элементы Цикл
					Если ЭлементОтбора.Использование Тогда
						НайденноеПоле = РабочийКомпоновщикНастроек.Настройки.ДоступныеПоляОтбора.НайтиПоле(Новый ПолеКомпоновкиДанных(ЭлементОтбора.ЛевоеЗначение));
						НайденноеПолеВыбора = РабочийКомпоновщикНастроек.Настройки.ДоступныеПоляВыбора.НайтиПоле(Новый ПолеКомпоновкиДанных(ЭлементОтбора.ЛевоеЗначение));
						ЯвляетсяРесурсом = НайденноеПолеВыбора <> Неопределено И НайденноеПолеВыбора.Ресурс;
						Если НайденноеПоле <> Неопределено И НЕ ЯвляетсяРесурсом Тогда // Не накладываем отборы на ресурсы.
							ТекЭлементОтбора = РабочийКомпоновщикНастроек.Настройки.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
							ТекЭлементОтбора.ЛевоеЗначение  = НайденноеПоле.Поле;
							ТекЭлементОтбора.ВидСравнения   = ЭлементОтбора.ВидСравнения;
							ТекЭлементОтбора.ПравоеЗначение = ЭлементОтбора.ПравоеЗначение;
							ТекЭлементОтбора.Использование  = Истина;
						КонецЕсли;
					КонецЕсли;
				КонецЦикла;
			КонецЕсли;
			
			Для Каждого ЭлементПараметр Из ОбщийОтбор.ПараметрыДанных.Элементы Цикл
				
				Если ЭлементПараметр.Использование И РабочийКомпоновщикНастроек.Настройки.ПараметрыДанных.ДоступныеПараметры.НайтиПараметр(ЭлементПараметр.Параметр) <> Неопределено Тогда
					РабочийКомпоновщикНастроек.Настройки.ПараметрыДанных.УстановитьЗначениеПараметра(ЭлементПараметр.Параметр, ЭлементПараметр.Значение);
				КонецЕсли;
				
			КонецЦикла;
			
		КонецЕсли;
		
		КомпоновщикМакета = Новый КомпоновщикМакетаКомпоновкиДанных;
		// Если источник - операнд внешней информационной базы
		ВнешниеНаборыДанных = Новый Структура;
		
		Если ТипЗнч(Объект.ИсточникДанныхОтчета) = Тип("СправочникСсылка.ИсточникиДанныхДляРасчетов") Тогда
			
			Контекст = Новый Структура;
			
			Для Каждого Параметр Из РабочийКомпоновщикНастроек.Настройки.ПараметрыДанных.Элементы Цикл
				Контекст.Вставить(Строка(Параметр.Параметр), Параметр.Значение);
			КонецЦикла;
			Контекст.Вставить("ИспользуемаяИБ", Объект.ИспользуемаяИБ);
			Контекст.Вставить("ЧтениеНеАктуальныхЗаписей", Истина);
			Контекст.Вставить("АнализЧувствительности", Ложь);
			
			ТаблицаЗначений = УправлениеОтчетамиУХ.ПолучитьТаблицуДанныхПоИсточнику(Контекст, Объект.ИсточникДанныхОтчета, Ложь);
			
			Если Объект.ИсточникДанныхОтчета.СпособПолучения=Перечисления.СпособыПолученияОперандов.ВнутренниеДанныеПоказательОтчета Тогда
				
				УправлениеОтчетамиУХ.ПреобразоватьТаблицуПоказателя(ТаблицаЗначений, Объект.ИсточникДанныхОтчета);
				
			КонецЕсли;
			
			Если ТипЗнч(ТаблицаЗначений) = тип("Структура") Тогда
				ВнешниеНаборыДанных.Вставить("ИсточникДанныхДляРасчетов", ТаблицаЗначений.ТаблицаДанных);
			Иначе
				ВнешниеНаборыДанных.Вставить("ИсточникДанныхДляРасчетов", ТаблицаЗначений);
			КонецЕсли;
		КонецЕсли;
		
		МакетКомпоновки = АналитическиеОтчетыУХ.ПолучитьМакетКомпоновки(ЗначенияНастроекПанелиПользователя, СхемаОтчета, РабочийКомпоновщикНастроек, ДанныеРасшифровки, ВнешниеНаборыДанных, Истина);
		ТиповыеОтчетыУХ.ДополнитьМакетыМакетаКомпоновкиРасшифровкойРесурсов(МакетКомпоновки, РабочийКомпоновщикНастроек);
		
		ПроцессорКомпоновки = Новый ПроцессорКомпоновкиДанных;
		ПроцессорКомпоновки.Инициализировать(МакетКомпоновки, ВнешниеНаборыДанных, ДанныеРасшифровки, Истина);
		
		// Аналитический отчет - панель индикаторов.
	Иначе
		
		Результат = ТЗОтвета.Скопировать();
		Возврат;
		
	КонецЕсли;
	
	Если ПараметрыОтчета <> Неопределено И ПараметрыОтчета.Свойство("ИспользоватьОграничениеВывода") И ПараметрыОтчета.ИспользоватьОграничениеВывода Тогда
		
		КоличествоЗаписей = 0;
		ОтносительноеКоличествоЗаписей = Ложь;
		
		ПараметрыОтчета.Свойство("КоличествоЗаписей", КоличествоЗаписей);
		ПараметрыОтчета.Свойство("ОтносительноеКоличествоЗаписей", ОтносительноеКоличествоЗаписей);
		
		Для Каждого ЭлементТела Из МакетКомпоновки.Тело Цикл
			Если ТипЗнч(ЭлементТела) = Тип("ЗаписиМакетаКомпоновкиДанных") Тогда
				Если ОтносительноеКоличествоЗаписей Тогда
					ЭлементТела.КоличествоЗаписей = КоличествоЗаписей;
				Иначе
					ЭлементТела.ПроцентЗаписей    = КоличествоЗаписей;
				КонецЕсли;
			КонецЕсли;
		КонецЦикла;
		
	КонецЕсли;
	
	//Очистим табличный документ - результат
	Результат.Очистить();
	
	//Создадим и инициализируем процессор вывода результата
	ПроцессорВывода = Новый ПроцессорВыводаРезультатаКомпоновкиДанныхВТабличныйДокумент;
	ПроцессорВывода.УстановитьДокумент(Результат);
	
	//Обозначим начало вывода
	ПроцессорВывода.НачатьВывод();
	
	//Основной цикл вывода отчета
	Пока Истина Цикл
		
		//Получим следующий элемент результата компоновки
		ЭлементРезультата = ПроцессорКомпоновки.Следующий();
		
		Если ЭлементРезультата = Неопределено Тогда
			//Следующий элемент не получен - заканчиваем цикл вывода
			Прервать;
			
		Иначе
			//Элемент получен - выведем его при помощи процессора вывода
			ПроцессорВывода.ВывестиЭлемент(ЭлементРезультата);
			
		КонецЕсли;
		
	КонецЦикла;
	
	//Обозначем завершение вывода
	ПроцессорВывода.ЗакончитьВывод();
	
	Если Результат.Рисунки.Количество() > 0 Тогда
		Рисунок = Результат.Рисунки[0];
		
		Если ТипЗнч(Рисунок.Объект) = Тип("Диаграмма") Тогда
			Параметр = Настройки.ПараметрыВывода.НайтиЗначениеПараметра(Новый ПараметрКомпоновкиДанных("ТипДиаграммы.РасположениеЛегенды"));
			Если Параметр.Использование И Параметр.Значение = РасположениеЛегендыДиаграммыКомпоновкиДанных.Нет Тогда
				
				Рисунок.Объект.ОтображатьЛегенду = Ложь;
				
			КонецЕсли;
		КонецЕсли;
		
	КонецЕсли;
	
	ТиповыеОтчетыУХ.ОтобразитьТрендГрафически(Результат);
	НастройкиКомпоновщика = РабочийКомпоновщикНастроек.ПолучитьНастройки();
	
	ТЗОтвета = Неопределено;
	
КонецПроцедуры

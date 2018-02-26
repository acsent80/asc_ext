﻿#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Параметры.Свойство("ДополнительнаяОбработкаСсылка", ДополнительнаяОбработкаСсылка);
	
	ВыполнятьвФоне = Истина;
	База = Справочники.ВнешниеИнформационныеБазы.НайтиПоНаименованию("Юникус");
	ВариантЗагрузки = "Период";
	
	ОбновитьДатуНаСервере();	
	
	Если НЕ ЗначениеЗаполнено(ДатаПоследненгоДокумента) Тогда
		ДатаПоследненгоДокумента = '2018-01-01';
	КонецЕсли;	
	
КонецПроцедуры

&НаСервере
Процедура ПриЗагрузкеДанныхИзНастроекНаСервере(Настройки)
	
	Элементы.Индикатор.Видимость = ВыполнятьвФоне;
	УстановитьТекстГруппыОтлдадки(ЭтаФорма);
	
	УстановитьВидимость(ЭтаФорма);
	
КонецПроцедуры

#КонецОбласти

&НаКлиентеНаСервереБезКонтекста
Процедура УстановитьТекстГруппыОтлдадки(ЭтаФорма)
	
	МассивСтрок = Новый Массив;
	Если ЗначениеЗаполнено(ЭтаФорма.Тест_КоличествоСтрок) Тогда
		МассивСтрок.Добавить("колво строк: " + ЭтаФорма.Тест_КоличествоСтрок);
	КонецЕсли;	
	
	Если ЗначениеЗаполнено(ЭтаФорма.Тест_Договор) Тогда
		МассивСтрок.Добавить("договор: " + ЭтаФорма.Тест_Договор);
	КонецЕсли;	
	
	Если ЗначениеЗаполнено(ЭтаФорма.Тест_VIN) Тогда
		МассивСтрок.Добавить("VIN: " + ЭтаФорма.Тест_VIN);
	КонецЕсли;	
	
	ЭтаФорма.ТекстГруппыОтладки = СтрСоединить(МассивСтрок, ", ");
	
КонецПроцедуры	

&НаКлиентеНаСервереБезКонтекста
Процедура УстановитьВидимость(ЭтаФорма)
	
	Если ЭтаФорма.Вариантзагрузки = "Период" Тогда
		ЭтаФорма.Элементы.Период.Видимость = Истина;
		ЭтаФорма.Элементы.ГруппаДатаПоследненгоДокумента.Видимость = Ложь;
	Иначе
		ЭтаФорма.Элементы.Период.Видимость = Ложь;
		ЭтаФорма.Элементы.ГруппаДатаПоследненгоДокумента.Видимость = Истина;
	КонецЕсли;	
	
КонецПроцедуры	

#Область ОбработчикиСобытийЭлементовФормы

&НаКлиенте
Процедура КолвоСтрокПриИзменении(Элемент)
	УстановитьТекстГруппыОтлдадки(ЭтаФорма);
КонецПроцедуры

&НаКлиенте
Процедура Тест_ДоговорПриИзменении(Элемент)
	УстановитьТекстГруппыОтлдадки(ЭтаФорма);
КонецПроцедуры

&НаКлиенте
Процедура Тест_VINПриИзменении(Элемент)
	УстановитьТекстГруппыОтлдадки(ЭтаФорма);
КонецПроцедуры

&НаКлиенте
Процедура ВариантЗагрузкиПриИзменении(Элемент)
	
	УстановитьВидимость(ЭтаФорма);
	
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьДату(Команда)
	ОбновитьДатуНаСервере();
КонецПроцедуры

&НаСервере
Процедура ОбновитьДатуНаСервере()
	
	Попытка
		ДатаПоследненгоДокумента = ХранилищеОбщихНастроек.Загрузить("ЗагрузкаДокументовИзUnicus", "ДатаПоследнегоДокумента",, "ЗагрузкаДокументовИзUnicus");
	Исключение
	КонецПопытки;
	
КонецПроцедуры

&НаКлиенте
Процедура ВыполнятьвФонеПриИзменении(Элемент)
	
	Элементы.Индикатор.Видимость = ВыполнятьвФоне;
	
КонецПроцедуры

#КонецОбласти

#Область ФоновоеВыполнение

&НаКлиенте
Процедура ПрогрессВыполнения(Результат, ДополнительныеПараметры) Экспорт
	
	Если Результат.Статус = "Выполняется" 
		ИЛИ Результат.Статус = "Выполнено" Тогда
		
		РезультатЗадания = ПрочитатьПрогрессИСообщения(Результат.ИдентификаторЗадания);
		Если РезультатЗадания.Прогресс <> Неопределено Тогда
			Индикатор = РезультатЗадания.Прогресс.Процент;
			Текст     = РезультатЗадания.Прогресс.Текст;
		КонецЕсли;
		
		Если РезультатЗадания.Сообщения <> Неопределено Тогда
			Для Каждого Сообщение Из РезультатЗадания.Сообщения Цикл
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(Сообщение.Текст, Сообщение.КлючДанных, Сообщение.Поле, Сообщение.ПутьКДанным);
			КонецЦикла;
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция ПрочитатьПрогрессИСообщения(ИдентификаторЗадания)
	Возврат ДлительныеОперации.ОперацияВыполнена(ИдентификаторЗадания, Истина, Истина, Истина);
КонецФункции

&НаКлиенте
Процедура ПослеФоновойОбработкиДанных(Задание, ДополнительныеПараметры) Экспорт
	
	Если Задание = Неопределено Тогда
		Возврат;
	КонецЕсли;	
	
	Если Задание.Статус = "Ошибка" Тогда
		
		ТекстОшибки = Задание.КраткоеПредставлениеОшибки;
		
		ОчиститьСообщения();
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстОшибки);
		
	ИначеЕсли Задание.Статус = "Выполнено" Тогда
		
		РезультатЗадания = ПрочитатьПрогрессИСообщения(ИдентификаторЗадания);
		Если РезультатЗадания.Сообщения <> Неопределено Тогда
			
			Для Каждого Сообщение Из РезультатЗадания.Сообщения Цикл
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(Сообщение.Текст, Сообщение.КлючДанных, Сообщение.Поле, Сообщение.ПутьКДанным);
			КонецЦикла;
			
		КонецЕсли;
		
		Состояние("Обработка завершена");
		ЗавершениеЗагрузки(Задание.АдресРезультата);
		
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ЗавершениеЗагрузки(АдресРезультата)
	
	Текст = "Обработка завершена";
	ОбновитьДатуНаСервере();
	
КонецПроцедуры

#КонецОбласти

#Область Реализация

&НаКлиенте
Процедура ЗагрузитьРеализации(Команда)
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ЗагрузитьРеализацииОтвет", ЭтотОбъект);
	ПоказатьВопрос(ОписаниеОповещения, "Загрузить реализации?", РежимДиалогаВопрос.ДаНет,, КодВозвратаДиалога.Нет);
	
КонецПроцедуры

&НаКлиенте
Процедура ЗагрузитьРеализацииОтвет(Ответ, ДополнительныеПараметры) Экспорт
	
	Если Ответ <> КодВозвратаДиалога.Да Тогда
		Возврат;
	КонецЕсли;
	
	ОчиститьСообщения();
	
	ОповещениеОПрогрессеВыполнения = Новый ОписаниеОповещения("ПрогрессВыполнения", ЭтотОбъект);
	Задание = ЗагрузитьРеализацииСервер();
	
	Если Задание <> Неопределено Тогда
		
		НастройкиОжидания = ДлительныеОперацииКлиент.ПараметрыОжидания(ЭтотОбъект);
		НастройкиОжидания.ВыводитьОкноОжидания = Ложь;
		НастройкиОжидания.ПолучатьРезультат    = Истина;
		НастройкиОжидания.ВыводитьСообщения    = Ложь;
		НастройкиОжидания.Интервал = 1;
		НастройкиОжидания.ОповещениеОПрогрессеВыполнения  = ОповещениеОПрогрессеВыполнения;
		НастройкиОжидания.ОповещениеПользователя.Показать = Ложь;
		
		Обработчик = Новый ОписаниеОповещения("ПослеФоновойОбработкиДанных", ЭтотОбъект);
		ДлительныеОперацииКлиент.ОжидатьЗавершение(Задание, Обработчик, НастройкиОжидания);
		
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Функция ЗагрузитьРеализацииСервер()
	
	СтруктураПараметров = Новый Структура;
	
	Если ВариантЗагрузки = "Период" Тогда
		СтруктураПараметров.Вставить("ДатаНач",        Период.ДатаНачала);
		СтруктураПараметров.Вставить("ДатаКон",        Период.ДатаОкончания);
	Иначе
		СтруктураПараметров.Вставить("ДатаНач",        ДатаПоследненгоДокумента);
		СтруктураПараметров.Вставить("ДатаКон",        '2100-01-01');
	КонецЕсли;	
	СтруктураПараметров.Вставить("База",               База);
	СтруктураПараметров.Вставить("Организация",        Организация);
	СтруктураПараметров.Вставить("ПерезаполнятьДокументы", ПерезаполнятьДокументы);
	СтруктураПараметров.Вставить("ПерезаполнятьДоговоры",  ПерезаполнятьДоговоры);
	СтруктураПараметров.Вставить("ВыводитьСообщения",      ВыводитьСообщения);
	СтруктураПараметров.Вставить("ОтложенноеПроведение",   ОтложенноеПроведение);
	СтруктураПараметров.Вставить("ЗагружатьДокументыОплаты", ЗагружатьДокументыОплаты);
	
	СтруктураПараметров.Вставить("Тест_КоличествоСтрок", Тест_КоличествоСтрок);
	СтруктураПараметров.Вставить("Тест_Договор",         Тест_Договор);
	СтруктураПараметров.Вставить("Тест_VIN",             Тест_VIN);
	
	СтруктураПараметров.Вставить("ИдентификаторФормы", ЭтаФорма.УникальныйИдентификатор);
	СтруктураПараметров.Вставить("ИмяФормы",           ЭтаФорма.ИмяФормы);
	ОбработкаОбъект = РеквизитФормыВЗначение("Объект");
	
	Индикатор = 0;
	Текст     = "";
	
	Если ВыполнятьвФоне Тогда
		
		Если ЗначениеЗаполнено(ИдентификаторЗадания) Тогда
			Попытка
				ЗаданиеВыполнено = ДлительныеОперации.ЗаданиеВыполнено(ИдентификаторЗадания);
			Исключение
				ЗаданиеВыполнено = Истина;
			КонецПопытки;
		Иначе
			ЗаданиеВыполнено = Истина;
		КонецЕсли;
		Если ЗаданиеВыполнено = Ложь Тогда
			// Надо ждать
			Возврат Неопределено;
		КонецЕсли;
		
		ВыполняемыйМетод = "ДлительныеОперации.ВыполнитьПроцедуруМодуляОбъектаОбработки";
		
		ЭтоВнешняяОбработка = Не Метаданные.Обработки.Содержит(ОбработкаОбъект.Метаданные());
		НаименованиеЗадания = ОбработкаОбъект.Метаданные().Представление();
	
		ПараметрыЗадания = Новый Структура;
		ПараметрыЗадания.Вставить("ИмяОбработки",                  ОбработкаОбъект.ИспользуемоеИмяФайла);
		ПараметрыЗадания.Вставить("ИмяМетода",                     "ЗагрузитьРеализации");
		ПараметрыЗадания.Вставить("ПараметрыВыполнения",           СтруктураПараметров);
		ПараметрыЗадания.Вставить("ЭтоВнешняяОбработка",           ЭтоВнешняяОбработка);
		ПараметрыЗадания.Вставить("ДополнительнаяОбработкаСсылка", ДополнительнаяОбработкаСсылка);
		
		ПараметрыВыполнения = ДлительныеОперации.ПараметрыВыполненияВФоне(ЭтаФорма.УникальныйИдентификатор);
		ПараметрыВыполнения.НаименованиеФоновогоЗадания = НаименованиеЗадания;
		ПараметрыВыполнения.ЗапуститьВФоне = Истина;
		
		РезультатФоновогоЗадания = ДлительныеОперации.ВыполнитьВФоне(ВыполняемыйМетод, ПараметрыЗадания, ПараметрыВыполнения);
		ИдентификаторЗадания = РезультатФоновогоЗадания.ИдентификаторЗадания;
		Возврат РезультатФоновогоЗадания;
		
	Иначе
		
		АдресРезультата = ПоместитьВоВременноеХранилище(Неопределено, ЭтаФорма.УникальныйИдентификатор);
		ОбработкаОбъект.ЗагрузитьРеализации(СтруктураПараметров, АдресРезультата);
		ЗавершениеЗагрузки(АдресРезультата);
		
	КонецЕсли;
	
КонецФункции

&НаКлиенте
Процедура ОткрытьРеализации(Команда)
	
	ОткрытьФорму("Документ.РеализацияТоваровУслуг.ФормаСписка");
	
КонецПроцедуры

#КонецОбласти





﻿
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Параметры.Свойство("ДополнительнаяОбработкаСсылка", ДополнительнаяОбработкаСсылка);
	
	ВыполнятьвФоне = Истина;
	База = Справочники.ВнешниеИнформационныеБазы.НайтиПоНаименованию("РИС");
	Тест_КодСтатьиДДС = "110007";
	
КонецПроцедуры

&НаСервере
Процедура ПриЗагрузкеДанныхИзНастроекНаСервере(Настройки)
	
	Элементы.Индикатор.Видимость = ВыполнятьвФоне;
	УстановитьТекстГруппыОтлдадки(ЭтаФорма);
	
КонецПроцедуры

#КонецОбласти

&НаКлиентеНаСервереБезКонтекста
Процедура УстановитьТекстГруппыОтлдадки(ЭтаФорма)
	
	МассивСтрок = Новый Массив;
	Если ЗначениеЗаполнено(ЭтаФорма.Тест_КоличествоСтрок) Тогда
		МассивСтрок.Добавить("колво строк: " + ЭтаФорма.Тест_КоличествоСтрок);
	КонецЕсли;	
	
	Если ЗначениеЗаполнено(ЭтаФорма.Тест_КодСтатьиДДС) Тогда
		МассивСтрок.Добавить("код статьи: " + ЭтаФорма.Тест_КодСтатьиДДС);
	КонецЕсли;	
	
	Если ЗначениеЗаполнено(ЭтаФорма.Тест_ВидДокумента) Тогда
		МассивСтрок.Добавить(ЭтаФорма.Тест_ВидДокумента);
	КонецЕсли;	
	
	ЭтаФорма.ТекстГруппыОтладки = СтрСоединить(МассивСтрок, ", ");
	
КонецПроцедуры	

#Область ОбработчикиСобытийЭлементовФормы

&НаКлиенте
Процедура КолвоСтрокПриИзменении(Элемент)
	УстановитьТекстГруппыОтлдадки(ЭтаФорма);
КонецПроцедуры

&НаКлиенте
Процедура Тест_КодСтатьиДДСПриИзменении(Элемент)
	УстановитьТекстГруппыОтлдадки(ЭтаФорма);
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
	
	КолвоДокументов = ПолучитьИзВременногоХранилища(АдресРезультата);
	
	Элементы.ФормаЗагрузитьПлатежи.Доступность = Истина;
	Текст = "Обработка завершена: " + КолвоДокументов + " документов";
	
КонецПроцедуры

#КонецОбласти

#Область ПолучениеДокументов

&НаКлиенте
Процедура ЗагрузитьПлатежи(Команда)
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ЗагрузитьПлатежиОтвет", ЭтотОбъект);
	ПоказатьВопрос(ОписаниеОповещения, "Загрузить платежи?", РежимДиалогаВопрос.ДаНет,, КодВозвратаДиалога.Нет);
	
КонецПроцедуры

&НаКлиенте
Процедура ЗагрузитьПлатежиОтвет(Ответ, ДополнительныеПараметры) Экспорт
	
	Если Ответ <> КодВозвратаДиалога.Да Тогда
		Возврат;
	КонецЕсли;
	
	ОчиститьСообщения();
	
	ОповещениеОПрогрессеВыполнения = Новый ОписаниеОповещения("ПрогрессВыполнения", ЭтотОбъект);
	Задание = ЗагрузитьПлатежиСервер();
	
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
Функция ЗагрузитьПлатежиСервер()
	
	СтруктураПараметров = Новый Структура;
	СтруктураПараметров.Вставить("ДатаНач",            Период.ДатаНачала);
	СтруктураПараметров.Вставить("ДатаКон",            Период.ДатаОкончания);
	СтруктураПараметров.Вставить("База",               База);
	СтруктураПараметров.Вставить("Организация",        Организация);
	СтруктураПараметров.Вставить("ПерезаполнятьДокументы", ПерезаполнятьДокументы);
	СтруктураПараметров.Вставить("ВыводитьСообщения",      ВыводитьСообщения);
	
	СтруктураПараметров.Вставить("Тест_КоличествоСтрок",  Тест_КоличествоСтрок);
	СтруктураПараметров.Вставить("Тест_КодСтатьиДДС",  	  СокрЛП(Тест_КодСтатьиДДС));
	СтруктураПараметров.Вставить("Тест_ВидДокумента",  	  СокрЛП(Тест_ВидДокумента));
	СтруктураПараметров.Вставить("Тест_Договор",  	      СокрЛП(Тест_Договор));
	
	СтруктураПараметров.Вставить("ИдентификаторФормы", ЭтаФорма.УникальныйИдентификатор);
	СтруктураПараметров.Вставить("ИмяФормы",           ЭтаФорма.ИмяФормы);
	ОбработкаОбъект = РеквизитФормыВЗначение("Объект");
	
	Индикатор = 0;
	Текст     = "";
	
	Элементы.ФормаЗагрузитьПлатежи.Доступность = Ложь;
	
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
		ПараметрыЗадания.Вставить("ИмяМетода",                     "ЗагрузитьПлатежи");
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
		ОбработкаОбъект.ЗагрузитьПлатежи(СтруктураПараметров, АдресРезультата);
		ЗавершениеЗагрузки(АдресРезультата);
		
	КонецЕсли;
	
КонецФункции

&НаКлиенте
Процедура ОткрытьДокументыПлатеж(Команда)
	
	ОткрытьФорму("Документ.АСЦ_Платеж.ФормаСписка");
	
КонецПроцедуры

#КонецОбласти

#Область КонвертацияПлатежей

&НаКлиенте
Процедура КонвертироватьПлатежи(Команда)
	
	ОписаниеОповещения = Новый ОписаниеОповещения("КонвертироватьПлатежиОтвет", ЭтотОбъект);
	ПоказатьВопрос(ОписаниеОповещения, "Конвертировать платежи?", РежимДиалогаВопрос.ДаНет,, КодВозвратаДиалога.Нет);
	
КонецПроцедуры

&НаКлиенте
Процедура КонвертироватьПлатежиОтвет(Ответ, ДополнительныеПараметры) Экспорт
	
	Если Ответ <> КодВозвратаДиалога.Да Тогда
		Возврат;
	КонецЕсли;
	
	ОчиститьСообщения();
	
	ОповещениеОПрогрессеВыполнения = Новый ОписаниеОповещения("ПрогрессВыполнения", ЭтотОбъект);
	Задание = КонвертироватьПлатежиСервер();
	
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
Функция КонвертироватьПлатежиСервер()
	
	СтруктураПараметров = Новый Структура;
	СтруктураПараметров.Вставить("ДатаНач",            Период.ДатаНачала);
	СтруктураПараметров.Вставить("ДатаКон",            Период.ДатаОкончания);
	СтруктураПараметров.Вставить("База",               База);
	СтруктураПараметров.Вставить("Организация",        Организация);
	СтруктураПараметров.Вставить("ПерезаполнятьДокументы", ПерезаполнятьДокументы);
	СтруктураПараметров.Вставить("ВыводитьСообщения",      ВыводитьСообщения);
	
	СтруктураПараметров.Вставить("Тест_КоличествоСтрок",  Тест_КоличествоСтрок);
	СтруктураПараметров.Вставить("Тест_КодСтатьиДДС",  	  СокрЛП(Тест_КодСтатьиДДС));
	СтруктураПараметров.Вставить("Тест_ВидДокумента",  	  СокрЛП(Тест_ВидДокумента));
	
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
		ПараметрыЗадания.Вставить("ИмяМетода",                     "КонвертироватьПлатежи");
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
		ОбработкаОбъект.КонвертироватьПлатежи(СтруктураПараметров, АдресРезультата);
		ЗавершениеЗагрузки(АдресРезультата);
		
	КонецЕсли;
	
КонецФункции

#КонецОбласти


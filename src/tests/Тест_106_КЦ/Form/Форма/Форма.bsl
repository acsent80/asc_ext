﻿&НаКлиенте
Перем КонтекстЯдра;
&НаКлиенте
Перем Ожидаем;
&НаКлиенте
Перем Утверждения;
&НаКлиенте
Перем ГенераторТестовыхДанных;
&НаКлиенте
Перем ЗапросыИзБД;
&НаКлиенте
Перем УтвержденияПроверкаТаблиц;

&НаКлиенте
Перем Форма;

#Область ЮнитТестирование

&НаКлиенте
Процедура Инициализация(КонтекстЯдраПараметр) Экспорт
	
	КонтекстЯдра = КонтекстЯдраПараметр;
	Ожидаем = КонтекстЯдра.Плагин("УтвержденияBDD");
	Утверждения = КонтекстЯдра.Плагин("БазовыеУтверждения");
	ГенераторТестовыхДанных = КонтекстЯдра.Плагин("СериализаторMXL");
	ЗапросыИзБД = КонтекстЯдра.Плагин("ЗапросыИзБД");
	УтвержденияПроверкаТаблиц = КонтекстЯдра.Плагин("УтвержденияПроверкаТаблиц");
	
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьНаборТестов(НаборТестов) Экспорт
	НаборТестов.НачатьГруппу("Тест_106_КЦ", Истина);
	НаборТестов.Добавить("Тест_106_КЦ_Январь");
	НаборТестов.Добавить("Тест_106_КЦ_Февраль");
КонецПроцедуры

&НаКлиенте
Процедура ПередЗапускомТеста() Экспорт
	
КонецПроцедуры

&НаКлиенте
Процедура ПослеЗапускаТеста() Экспорт
	
	Попытка
		Форма.Модифицированность = Ложь;
		Форма.Закрыть();
	Исключение
	КонецПопытки;	
	
КонецПроцедуры

#КонецОбласти

&НаКлиенте
Процедура Тест_106_КЦ_Январь() Экспорт
	
	Макет = ПолучитьМакет("ДанныеЯнварь");
	СтруктураДанных = ГенераторТестовыхДанных.СоздатьДанныеПоТабличномуДокументу(Макет,,, Истина);
	
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("Ключ", СтруктураДанных.НастраиваемыйОтчет1);
	
	Форма = ПолучитьФорму("Документ.НастраиваемыйОтчет.ФормаОбъекта", ПараметрыФормы);
	Форма.Открыть();
	
	Форма.тестВключитьРедактирование();
	Форма.ДействияФормыОчиститьЗавершение(КодВозвратаДиалога.Да, Неопределено);
	
	Форма.ВычислятьПриИзменении = Ложь;
	Форма.Элементы.ДействияФормыВычислятьПриИзменении.Пометка = Ложь;
	
	ТабОригинал = ПолучитьМакет("РезультатЯнварь");
	Форма.тестЗаполнитьДокументПоМакету(ТабОригинал, 3);
	
	Форма.тестПересчитатьВычисляемыеПоказатели();
	
	// Эти показатели вводятся для января и рассчитываются для остальных месяцев
	Форма.ВычислятьПриИзменении = Истина;
	Форма.Элементы.ДействияФормыВычислятьПриИзменении.Пометка = Истина;
	
	Форма.тестУстановитьЗначениеОбласти("ВозвратныйРемресурс_План",  8000);
	Форма.тестУстановитьЗначениеОбласти("РеальныВозвратРемрес_План", 8000);
	
	Форма.тестУстановитьСтатус(ПредопределенноеЗначение("Перечисление.СостоянияОтчетов.Подготовлен"));
	Форма.Записать();
	
	ТабДокумент = Форма.тестТабДокСПоказателями();
	УтвержденияПроверкаТаблиц.ПроверитьРавенствоТабличныхДокументовТолькоПоЗначениям(ПолучитьОбласть(ТабОригинал, 13), ПолучитьОбласть(ТабДокумент, 13),, "Не совпал результат");
	
КонецПроцедуры	

&НаКлиенте
Процедура Тест_106_КЦ_Февраль() Экспорт
	
	Макет = ПолучитьМакет("ДанныеФевраль");
	СтруктураДанных = ГенераторТестовыхДанных.СоздатьДанныеПоТабличномуДокументу(Макет,,, Истина);
	
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("Ключ", СтруктураДанных.НастраиваемыйОтчет1);
	
	Форма = ПолучитьФорму("Документ.НастраиваемыйОтчет.ФормаОбъекта", ПараметрыФормы);
	Форма.Открыть();
	
	Форма.тестВключитьРедактирование();
	Форма.ДействияФормыОчиститьЗавершение(КодВозвратаДиалога.Да, Неопределено);
	
	Форма.ВычислятьПриИзменении = Ложь;
	Форма.Элементы.ДействияФормыВычислятьПриИзменении.Пометка = Ложь;
	
	ТабОригинал = ПолучитьМакет("РезультатФевраль");
	Форма.тестЗаполнитьДокументПоМакету(ТабОригинал, 3);
	
	Форма.тестПересчитатьВычисляемыеПоказатели();
	
	Форма.тестУстановитьСтатус(ПредопределенноеЗначение("Перечисление.СостоянияОтчетов.Подготовлен"));
	Форма.Записать();
	
	ТабДокумент = Форма.тестТабДокСПоказателями();
	УтвержденияПроверкаТаблиц.ПроверитьРавенствоТабличныхДокументовТолькоПоЗначениям(ПолучитьОбласть(ТабОригинал, 13), ПолучитьОбласть(ТабДокумент, 13),, "Не совпал результат");
	
КонецПроцедуры	

&НаСервереБезКонтекста
Функция ПолучитьОбласть(ТабОригинал, НомерСтроки)
	
	Возврат ТабОригинал.ПолучитьОбласть(НомерСтроки, 1,,);
	
КонецФункции	

&НаСервере
Функция ПолучитьМакет(ИмяМакета = "Данные")
	
	ОбработкаОбъект = РеквизитФормыВЗначение("Объект");
	Возврат ОбработкаОбъект.ПолучитьМакет(ИмяМакета);
	
КонецФункции
	
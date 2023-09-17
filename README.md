# setup_comp
Скрипт автоматизации настройки М ОС

Скрипт для настройки рабочего места. Имеет графический и консольный интерфейс. Переключение между осуществляется настройкой в скрипте параметром use_gui=true / false.
Также, если раскомментировать параметры с паролями, то  будут использованы указанные, в противном случае будут запросы паролей при настройке.<br/>
Для настройки ключей ssh и veyon необходимые файлы должны лежать в папке с скриптом.
Для выполнения сразу нескольких команд:<br/>
-в консольном режиме через пробел указать номера пунктов настроек<br/>
-в графическом просто отметить мышкой необходимые пункты<br/>
Можно скопировать руту в ~/ и использовать как траблшутинг

Список меню:
<il>
<li>"Обновить систему"</li>
<li>"Переименовать компьютер (требуется перезагрузка)"</li>
<li>"Создать пользователей по умолчанию"</li>
<li>"Пересоздать учетную запись Ученика"</li>
<li>"Заблокировать Рабочий стол Ученика"</li>
<li>"Разблокировать Рабочий стол Ученика"</li>
<li>"Установить автологин"</li>
<li>"Установить открытый ssh ключ для root"</li>
<li>"Установить и настроить Veyon"</li>
<li>"Убрать меню GRUB"</li>
<li>"Убрать 30-секундное ожидание у учетной записи Ученика"</li>
<li>"Chrome по умолчанию у Ученика"</li>
<li>"Удалить учетку User"</li>
<li>"Переустановить KDE Plasma"</li>
<li>"Включить WoL"</li>
<li>"Включить авторизацию через mos.ru"</li>
<li>"Отключить авторизацию через mos.ru"</li>
<li>"Включить гостевой вход"</li>
<li>"Отключить гостевой вход"</li>
<li>"Перезагрузить"</li>
</il>

![Графический режим](https://github.com/xp9k/setup_comp/blob/main/Screenshot_1.png)
![Консольный режим](https://github.com/xp9k/setup_comp/blob/main/Screenshot_2.png)

using Gtk;
using GLib;
using Adw;
using Gee;

public class MangoJuice : Adw.Application {
    private Button saveButton;
    private Button resetButton;
    private Button logsPathButton; // Добавляем кнопку для выбора пути к логам
    private Switch[] gpu_switches;
    private Switch[] cpu_switches;
    private Switch[] other_switches;
    private Switch[] system_switches;
    private Switch[] wine_switches;
    private Switch[] options_switches;
    private Switch[] battery_switches;
    private Switch[] other_extra_switches;
    private Label[] gpu_labels;
    private Label[] cpu_labels;
    private Label[] other_labels;
    private Label[] system_labels;
    private Label[] wine_labels;
    private Label[] options_labels;
    private Label[] battery_labels;
    private Label[] other_extra_labels;
    private Entry custom_command_entry;
    private Entry custom_logs_path_entry;
    private DropDown logs_key_combo;
    private StringList logs_key_model;
    private Scale duracion_scale;
    private Scale autostart_scale;
    private Scale interval_scale;
    private Label duracion_value_label;
    private Label autostart_value_label;
    private Label interval_value_label;

    private const string GPU_TITLE = "GPU";
    private const string CPU_TITLE = "CPU";
    private const string OTHER_TITLE = "Other";
    private const string SYSTEM_TITLE = "System";
    private const string WINE_TITLE = "Wine";
    private const string OPTIONS_TITLE = "Options";
    private const string BATTERY_TITLE = "Battery";
    private const string OTHER_EXTRA_TITLE = "Other Extras";

    private const int GPU_SWITCHES_COUNT = 15;
    private const int CPU_SWITCHES_COUNT = 6;
    private const int OTHER_SWITCHES_COUNT = 4;
    private const int SYSTEM_SWITCHES_COUNT = 6;
    private const int WINE_SWITCHES_COUNT = 3;
    private const int OPTIONS_SWITCHES_COUNT = 6;
    private const int BATTERY_SWITCHES_COUNT = 4;
    private const int OTHER_EXTRA_SWITCHES_COUNT = 5;
    private const int MAIN_BOX_SPACING = 10;
    private const int FLOW_BOX_ROW_SPACING = 10;
    private const int FLOW_BOX_COLUMN_SPACING = 10;
    private const int FLOW_BOX_MARGIN = 10;

    private bool vkcube_was_running = false;

    private string[] gpu_config_vars = {
        "gpu_stats", "gpu_load_change", "vram", "gpu_core_clock", "gpu_mem_clock",
        "gpu_temp", "gpu_mem_temp", "gpu_junction_temp", "gpu_fan", "gpu_name",
        "gpu_power", "gpu_voltage", "throttling_status", "throttling_status_graph", "vulkan_driver"
    };
    private string[] cpu_config_vars = {
        "cpu_stats", "cpu_load_change", "core_load", "cpu_mhz", "cpu_temp",
        "cpu_power"
    };
    private string[] other_config_vars = {
        "ram", "io_stats", "procmem", "swap"
    };
    private string[] system_config_vars = {
        "exec=uname -r", "refresh_rate", "resolution", "exec=echo $XDG_SESSION_TYPE",
        "time", "arch"
    };
    private string[] wine_config_vars = {
        "wine", "engine", "engine_short_names"
    };
    private string[] options_config_vars = {
        "version", "gamemode", "vkbasalt", "fcat", "fsr", "hdr"
    };
    private string[] battery_config_vars = {
        "battery", "battery_watt", "battery_time", "device_battery"
    };
    private string[] other_extra_config_vars = {
        "media_player", "network", "full", "log_versioning", "upload_logs"
    };
    private string[] gpu_label_texts = {
        "GPU Load", "Load Color", "VRAM", "Core Freq", "Mem Freq",
        "GPU Temp", "Memory Temp", "Juntion", "Fans", "Model",
        "Power", "Voltage", "Throttling", "Throttling GRAPH", "Vulcan Driver"
    };
    private string[] cpu_label_texts = {
        "CPU Load", "CPU Load Color", "CPU Core Load", "CPU Freq", "CPU Temp",
        "CPU Power"
    };
    private string[] other_label_texts = {
        "RAM", "Disk IO", "Procces", "Swap"
    };
    private string[] system_label_texts = {
        "Distro", "Refresh rate*", "Resolution", "Session",
        "Time", "Arch"
    };
    private string[] wine_label_texts = {
        "Version", "Engine Ver", "Short names"
    };
    private string[] options_label_texts = {
        "Hud Version", "Gamemode", "VKbasalt", "Fcat", "FSR*", "HDR*"
    };
    private string[] battery_label_texts = {
        "Percentage", "Wattage", "Time remain", "Device"
    };
    private string[] other_extra_label_texts = {
        "Media Info", "Network", "Full ON", "Log Versioning", "Avtoupload Results"
    };

    public MangoJuice() {
        Object(application_id: "com.radiolamp.mangojuice", flags: ApplicationFlags.DEFAULT_FLAGS);
        set_resource_base_path("/usr/local/share/icons/hicolor/scalable/apps/");
    }

    protected override void activate() {
        var window = new Adw.ApplicationWindow(this);
        window.set_default_size(970, 600);
        window.set_title("MangoJuice");

        var main_box = new Box(Orientation.VERTICAL, MAIN_BOX_SPACING);
        main_box.set_homogeneous(false);

        var scrolled_window = new ScrolledWindow();
        scrolled_window.set_policy(PolicyType.NEVER, PolicyType.AUTOMATIC);
        scrolled_window.set_vexpand(true);

        var view_stack = new ViewStack();
        var toolbar_view_switcher = new ViewSwitcher();
        toolbar_view_switcher.stack = view_stack;

        var box1 = new Box(Orientation.VERTICAL, MAIN_BOX_SPACING);
        var box2 = new Box(Orientation.VERTICAL, MAIN_BOX_SPACING);
        var box3 = new Box(Orientation.VERTICAL, MAIN_BOX_SPACING);
        var box4 = new Box(Orientation.VERTICAL, MAIN_BOX_SPACING);

        gpu_switches = new Switch[GPU_SWITCHES_COUNT];
        cpu_switches = new Switch[CPU_SWITCHES_COUNT];
        other_switches = new Switch[OTHER_SWITCHES_COUNT];
        system_switches = new Switch[SYSTEM_SWITCHES_COUNT];
        wine_switches = new Switch[WINE_SWITCHES_COUNT];
        options_switches = new Switch[OPTIONS_SWITCHES_COUNT];
        battery_switches = new Switch[BATTERY_SWITCHES_COUNT];
        other_extra_switches = new Switch[OTHER_EXTRA_SWITCHES_COUNT];

        gpu_labels = new Label[GPU_SWITCHES_COUNT];
        cpu_labels = new Label[CPU_SWITCHES_COUNT];
        other_labels = new Label[OTHER_SWITCHES_COUNT];
        system_labels = new Label[SYSTEM_SWITCHES_COUNT];
        wine_labels = new Label[WINE_SWITCHES_COUNT];
        options_labels = new Label[OPTIONS_SWITCHES_COUNT];
        battery_labels = new Label[BATTERY_SWITCHES_COUNT];
        other_extra_labels = new Label[OTHER_EXTRA_SWITCHES_COUNT];

        create_switches_and_labels(box1, GPU_TITLE, gpu_switches, gpu_labels, gpu_config_vars, gpu_label_texts, GPU_SWITCHES_COUNT);
        create_switches_and_labels(box1, CPU_TITLE, cpu_switches, cpu_labels, cpu_config_vars, cpu_label_texts, CPU_SWITCHES_COUNT);
        create_switches_and_labels(box1, OTHER_TITLE, other_switches, other_labels, other_config_vars, other_label_texts, OTHER_SWITCHES_COUNT);

        create_switches_and_labels(box2, SYSTEM_TITLE, system_switches, system_labels, system_config_vars, system_label_texts, SYSTEM_SWITCHES_COUNT);
        create_switches_and_labels(box2, WINE_TITLE, wine_switches, wine_labels, wine_config_vars, wine_label_texts, WINE_SWITCHES_COUNT);
        create_switches_and_labels(box2, OPTIONS_TITLE, options_switches, options_labels, options_config_vars, options_label_texts, OPTIONS_SWITCHES_COUNT);
        create_switches_and_labels(box2, BATTERY_TITLE, battery_switches, battery_labels, battery_config_vars, battery_label_texts, BATTERY_SWITCHES_COUNT);
        create_switches_and_labels(box2, OTHER_EXTRA_TITLE, other_extra_switches, other_extra_labels, other_extra_config_vars, other_extra_label_texts, OTHER_EXTRA_SWITCHES_COUNT);

        create_scales_and_labels(box2);

        view_stack.add_titled(box1, "box1", "Metrics").icon_name = "view-continuous-symbolic";
        view_stack.add_titled(box2, "box2", "Extras").icon_name = "application-x-addon-symbolic";
        view_stack.add_titled(box3, "box3", "Performance").icon_name = "emblem-system-symbolic";
        view_stack.add_titled(box4, "box4", "Visual").icon_name = "preferences-desktop-appearance-symbolic";

        custom_command_entry = new Entry();
        custom_command_entry.placeholder_text = "Raw Custom Cmd";

        custom_logs_path_entry = new Entry();
        custom_logs_path_entry.placeholder_text = "Home";

        logsPathButton = new Button.with_label("Folder logs"); // Добавляем кнопку
        logsPathButton.clicked.connect(() => {
            open_folder_chooser_dialog();
        });

        var logs_key_strings = new string[] { "Shift_L+F2", "Shift_L+F3", "Shift_L+F4", "Shift_L+F5" };
        logs_key_model = new StringList(logs_key_strings);

        var logs_key_factory = new SignalListItemFactory();
        logs_key_factory.setup.connect((item) => {
            var list_item = item as ListItem;
            var label = new Label("");
            list_item.set_child(label);
        });
        logs_key_factory.bind.connect((item) => {
            var list_item = item as ListItem;
            var label = list_item.get_child() as Label;
            if (list_item.item != null) {
                label.label = (list_item.item as StringObject).get_string();
            }
        });

        logs_key_combo = new DropDown(logs_key_model, null);
        logs_key_combo.notify["selected-item"].connect(() => {
            if (logs_key_combo.selected_item != null) {
                update_logs_key_in_file((logs_key_combo.selected_item as StringObject).get_string());
            }
        });

        resetButton = new Button.with_label("Reset Config");
        resetButton.add_css_class("destructive-action");
        resetButton.clicked.connect(() => {
            delete_mangohub_conf();
            restart_mangohud();
        });

        var custom_command_box = new Box(Orientation.HORIZONTAL, MAIN_BOX_SPACING);
        custom_command_box.set_margin_start(FLOW_BOX_MARGIN);
        custom_command_box.set_margin_end(FLOW_BOX_MARGIN);
        custom_command_box.set_margin_top(FLOW_BOX_MARGIN);
        custom_command_box.set_margin_bottom(FLOW_BOX_MARGIN);

        custom_command_box.append(custom_command_entry);
        custom_command_box.append(new Label("Logs key"));
        custom_command_box.append(logs_key_combo);
        custom_command_box.append(new Label(""));
        custom_command_box.append(custom_logs_path_entry);
        custom_command_box.append(logsPathButton); // Добавляем кнопку в контейнер
        custom_command_box.append(resetButton);

        box2.append(custom_command_box);

        var header_bar = new Adw.HeaderBar();
        header_bar.set_title_widget(toolbar_view_switcher);

        saveButton = new Button.with_label("Save");
        saveButton.add_css_class("suggested-action");
        header_bar.pack_end(saveButton);

        saveButton.clicked.connect(() => {
            save_states_to_file();
            if (vkcube_was_running) {
                restart_mangohud();
            } else {
                warning("vkcube was not running before saving. Restart aborted.");
            }
        });

        var testButton = new Button.with_label("Test");
        testButton.clicked.connect(() => {
            try {
                Process.spawn_command_line_sync("pkill vkcube");
                Process.spawn_command_line_async("mangohud vkcube");
            } catch (Error e) {
                stderr.printf("Ошибка при запуске команды: %s\n", e.message);
            }
        });
        header_bar.pack_start(testButton);

        var content_box = new Box(Orientation.VERTICAL, 0);
        content_box.append(header_bar);
        content_box.append(scrolled_window);
        window.set_content(content_box);

        scrolled_window.set_child(view_stack);

        window.present();

        load_states_from_file();

        vkcube_was_running = is_vkcube_running();

        window.close_request.connect(() => {
            if (vkcube_was_running) {
                try {
                    Process.spawn_command_line_sync("pkill vkcube");
                } catch (Error e) {
                    stderr.printf("Ошибка при закрытии vkcube: %s\n", e.message);
                }
            }
            return false;
        });
    }

    private void create_switches_and_labels(Box parent_box, string title, Switch[] switches, Label[] labels, string[] config_vars, string[] label_texts, int count) {
        var label = new Label(title);
        label.set_halign(Align.CENTER);
        label.set_margin_top(FLOW_BOX_MARGIN);
        label.set_margin_start(FLOW_BOX_MARGIN);
        label.set_margin_end(FLOW_BOX_MARGIN);
        parent_box.append(label);

        var flow_box = new FlowBox();
        flow_box.set_homogeneous(true);
        flow_box.set_max_children_per_line(6);
        flow_box.set_min_children_per_line(3);
        flow_box.set_row_spacing(FLOW_BOX_ROW_SPACING);
        flow_box.set_column_spacing(FLOW_BOX_COLUMN_SPACING);
        flow_box.set_margin_start(FLOW_BOX_MARGIN);
        flow_box.set_margin_end(FLOW_BOX_MARGIN);
        flow_box.set_margin_top(FLOW_BOX_MARGIN);
        flow_box.set_margin_bottom(FLOW_BOX_MARGIN);
        flow_box.set_selection_mode(SelectionMode.NONE);

        for (int i = 0; i < count; i++) {
            var row_box = new Box(Orientation.HORIZONTAL, MAIN_BOX_SPACING);
            switches[i] = new Switch();
            labels[i] = new Label(label_texts[i]);
            labels[i].set_halign(Align.START);
            row_box.append(switches[i]);
            row_box.append(labels[i]);
            flow_box.insert(row_box, -1);
        }

        parent_box.append(flow_box);
    }

    private void create_scales_and_labels(Box parent_box) {
        duracion_scale = new Scale.with_range(Orientation.HORIZONTAL, 0, 200, 1);
        duracion_scale.set_value(0);
        duracion_scale.set_hexpand(true);
        duracion_scale.set_margin_start(FLOW_BOX_MARGIN);
        duracion_scale.set_margin_end(FLOW_BOX_MARGIN);
        duracion_scale.set_margin_top(FLOW_BOX_MARGIN);
        duracion_scale.set_margin_bottom(FLOW_BOX_MARGIN);
        duracion_value_label = new Label("");
        duracion_value_label.set_halign(Align.END);
        duracion_scale.value_changed.connect(() => {
            duracion_value_label.label = "%d s".printf((int)duracion_scale.get_value());
        });

        autostart_scale = new Scale.with_range(Orientation.HORIZONTAL, 0, 30, 1);
        autostart_scale.set_value(0);
        autostart_scale.set_hexpand(true);
        autostart_scale.set_margin_start(FLOW_BOX_MARGIN);
        autostart_scale.set_margin_end(FLOW_BOX_MARGIN);
        autostart_scale.set_margin_top(FLOW_BOX_MARGIN);
        autostart_scale.set_margin_bottom(FLOW_BOX_MARGIN);
        autostart_value_label = new Label("");
        autostart_value_label.set_halign(Align.END);
        autostart_scale.value_changed.connect(() => {
            autostart_value_label.label = "%d s".printf((int)autostart_scale.get_value());
        });

        interval_scale = new Scale.with_range(Orientation.HORIZONTAL, 0, 500, 1);
        interval_scale.set_value(0);
        interval_scale.set_hexpand(true);
        interval_scale.set_margin_start(FLOW_BOX_MARGIN);
        interval_scale.set_margin_end(FLOW_BOX_MARGIN);
        interval_scale.set_margin_top(FLOW_BOX_MARGIN);
        interval_scale.set_margin_bottom(FLOW_BOX_MARGIN);
        interval_value_label = new Label("");
        interval_value_label.set_halign(Align.END);
        interval_scale.value_changed.connect(() => {
            interval_value_label.label = "%d ms".printf((int)interval_scale.get_value());
        });

        var scales_box = new Box(Orientation.HORIZONTAL, MAIN_BOX_SPACING);
        scales_box.set_margin_start(FLOW_BOX_MARGIN);
        scales_box.set_margin_end(FLOW_BOX_MARGIN);
        scales_box.set_margin_top(FLOW_BOX_MARGIN);
        scales_box.set_margin_bottom(FLOW_BOX_MARGIN);

        scales_box.append(new Label("Duracion"));
        scales_box.append(duracion_scale);
        scales_box.append(duracion_value_label);
        scales_box.append(new Label("Autostart"));
        scales_box.append(autostart_scale);
        scales_box.append(autostart_value_label);
        scales_box.append(new Label("Interval"));
        scales_box.append(interval_scale);
        scales_box.append(interval_value_label);

        var logging_label = new Label("Logging");
        logging_label.set_valign(Align.CENTER);
        logging_label.set_margin_top(FLOW_BOX_MARGIN);
        logging_label.set_margin_start(FLOW_BOX_MARGIN);
        logging_label.set_margin_end(FLOW_BOX_MARGIN);
        parent_box.append(logging_label);
        parent_box.append(scales_box);
    }

    private void save_states_to_file() {
        var config_dir = File.new_for_path(Environment.get_home_dir()).get_child(".config").get_child("MangoHud");
        if (!config_dir.query_exists()) {
            try {
                config_dir.make_directory_with_parents();
            } catch (Error e) {
                stderr.printf("Ошибка при создании директории: %s\n", e.message);
                return;
            }
        }

        var file = config_dir.get_child("MangoHud.conf");
        try {
            var file_stream = file.replace(null, false, FileCreateFlags.NONE);
            var data_stream = new DataOutputStream(file_stream);

            data_stream.put_string("################### File Generated by MangoJuice ###################\n");
            data_stream.put_string("legacy_layout=false\n");
            data_stream.put_string("fps\n");
            
            save_switches_to_file(data_stream, gpu_switches, gpu_config_vars);
            save_switches_to_file(data_stream, cpu_switches, cpu_config_vars);
            save_switches_to_file(data_stream, other_switches, other_config_vars);
            save_switches_to_file(data_stream, system_switches, system_config_vars);
            save_switches_to_file(data_stream, wine_switches, wine_config_vars);
            save_switches_to_file(data_stream, options_switches, options_config_vars);
            save_switches_to_file(data_stream, battery_switches, battery_config_vars);
            save_switches_to_file(data_stream, other_extra_switches, other_extra_config_vars);

            var custom_command = custom_command_entry.text;
            if (custom_command != "") {
                data_stream.put_string("%s\n".printf(custom_command));
            }

            if (logs_key_combo.selected_item != null) {
                var logs_key = (logs_key_combo.selected_item as StringObject).get_string();
                if (logs_key != "") {
                    data_stream.put_string("toggle_logging=%s\n".printf(logs_key));
                }
            }

            data_stream.put_string("log_duracion=%d\n".printf((int)duracion_scale.get_value()));
            data_stream.put_string("autostart_log=%d\n".printf((int)autostart_scale.get_value()));
            data_stream.put_string("log_interval=%d\n".printf((int)interval_scale.get_value()));

            var custom_logs_path = custom_logs_path_entry.text;
            if (custom_logs_path != "") {
                data_stream.put_string("output_folder=%s\n".printf(custom_logs_path));
            }

            data_stream.close();
        } catch (Error e) {
            stderr.printf("Ошибка при записи в файл: %s\n", e.message);
        }
    }

    private void save_switches_to_file(DataOutputStream data_stream, Switch[] switches, string[] config_vars) {
        for (int i = 0; i < switches.length; i++) {
            var state = switches[i].active ? "" : "#";
            try {
                data_stream.put_string("%s%s\n".printf(state, config_vars[i]));
            } catch (Error e) {
                stderr.printf("Ошибка при записи в файл: %s\n", e.message);
            }
        }
    }

    private void load_states_from_file() {
        var config_dir = File.new_for_path(Environment.get_home_dir()).get_child(".config").get_child("MangoHud");
        var file = config_dir.get_child("MangoHud.conf");
        if (!file.query_exists()) {
            return;
        }

        try {
            var file_stream = new DataInputStream(file.read());
            string line;
            while ((line = file_stream.read_line()) != null) {
                load_switch_from_file(line, gpu_switches, gpu_config_vars);
                load_switch_from_file(line, cpu_switches, cpu_config_vars);
                load_switch_from_file(line, other_switches, other_config_vars);
                load_switch_from_file(line, system_switches, system_config_vars);
                load_switch_from_file(line, wine_switches, wine_config_vars);
                load_switch_from_file(line, options_switches, options_config_vars);
                load_switch_from_file(line, battery_switches, battery_config_vars);
                load_switch_from_file(line, other_extra_switches, other_extra_config_vars);

                if (line.has_prefix("custom_command=")) {
                    var custom_command = line.substring("custom_command=".length);
                    custom_command_entry.text = custom_command;
                }

                if (line.has_prefix("toggle_logging=")) {
                    var logs_key = line.substring("toggle_logging=".length);
                    for (uint i = 0; i < logs_key_model.get_n_items(); i++) {
                        var item = logs_key_model.get_item(i) as StringObject;
                        if (item != null && item.get_string() == logs_key) {
                            logs_key_combo.selected = i;
                            break;
                        }
                    }
                }

                if (line.has_prefix("Custom=Duracion:")) {
                    var value = int.parse(line.substring("Custom=Duracion:".length));
                    duracion_scale.set_value(value);
                    duracion_value_label.label = "%d".printf(value);
                }
                if (line.has_prefix("Custom=Autostart:")) {
                    var value = int.parse(line.substring("Custom=Autostart:".length));
                    autostart_scale.set_value(value);
                    autostart_value_label.label = "%d".printf(value);
                }
                if (line.has_prefix("Custom=Interval:")) {
                    var value = int.parse(line.substring("Custom=Interval:".length));
                    interval_scale.set_value(value);
                    interval_value_label.label = "%d".printf(value);
                }

                if (line.has_prefix("custom_logs_path=")) {
                    var custom_logs_path = line.substring("custom_logs_path=".length);
                    custom_logs_path_entry.text = custom_logs_path;
                }
            }
        } catch (Error e) {
            stderr.printf("Ошибка при чтении файла: %s\n", e.message);
        }
    }

    private void load_switch_from_file(string line, Switch[] switches, string[] config_vars) {
        for (int i = 0; i < config_vars.length; i++) {
            if (line.has_prefix("#%s".printf(config_vars[i]))) {
                switches[i].active = false;
            } else if (line.has_prefix("%s".printf(config_vars[i]))) {
                switches[i].active = true;
            }
        }
    }

    private void restart_mangohud() {
        try {
            string[] argv = { "pgrep", "mangohud" };
            int exit_status;
            string standard_output;
            string standard_error;
            Process.spawn_sync(null, argv, null, SpawnFlags.SEARCH_PATH, null, out standard_output, out standard_error, out exit_status);

            if (exit_status == 0) {
                Process.spawn_command_line_sync("pkill vkcube");
                Process.spawn_command_line_async("mangohud vkcube");
            }
        } catch (Error e) {
            stderr.printf("Ошибка при перезапуске mangohud: %s\n", e.message);
        }
    }

    private bool is_vkcube_running() {
        try {
            string[] argv = { "pgrep", "vkcube" };
            int exit_status;
            string standard_output;
            string standard_error;
            Process.spawn_sync(null, argv, null, SpawnFlags.SEARCH_PATH, null, out standard_output, out standard_error, out exit_status);

            return exit_status == 0;
        } catch (Error e) {
            stderr.printf("Ошибка при проверке запущенных процессов: %s\n", e.message);
            return false;
        }
    }

    private void delete_mangohub_conf() {
        var config_dir = File.new_for_path(Environment.get_home_dir()).get_child(".config").get_child("MangoHud");
        var file = config_dir.get_child("MangoHud.conf");
        if (file.query_exists()) {
            try {
                file.delete();
                warning("MangoHud.conf file deleted.");
            } catch (Error e) {
                stderr.printf("Ошибка при удалении файла: %s\n", e.message);
            }
        } else {
            warning("MangoHud.conf file does not exist.");
        }
    }

    private void update_logs_key_in_file(string logs_key) {
        var config_dir = File.new_for_path(Environment.get_home_dir()).get_child(".config").get_child("MangoHud");
        var file = config_dir.get_child("MangoHud.conf");
        if (!file.query_exists()) {
            return;
        }

        try {
            var lines = new ArrayList<string>();
            var file_stream = new DataInputStream(file.read());
            string line;
            while ((line = file_stream.read_line()) != null) {
                if (line.has_prefix("toggle_logging=")) {
                    line = "toggle_logging=%s".printf(logs_key);
                }
                lines.add(line);
            }

            var file_stream_write = new DataOutputStream(file.replace(null, false, FileCreateFlags.NONE));
            foreach (var l in lines) {
                file_stream_write.put_string(l + "\n");
            }
            file_stream_write.close();
        } catch (Error e) {
            stderr.printf("Ошибка при записи в файл: %s\n", e.message);
        }
    }

    private void open_folder_chooser_dialog() {
        var dialog = new Gtk.FileDialog();
        dialog.select_folder.begin(this.active_window, null, (obj, res) => {
            try {
                var folder = dialog.select_folder.end(res);
                custom_logs_path_entry.text = folder.get_path();
            } catch (Error e) {
                stderr.printf("Ошибка при выборе папки: %s\n", e.message);
            }
        });
    }

    public static int main(string[] args) {
        var app = new MangoJuice();
        return app.run(args);
    }
}
           
import * as gulp from "gulp";
import * as rename from "gulp-rename";
import * as gulpReplace from "gulp-replace";
import * as gulpPbo from "gulp-armapbo";
import * as gulpZip from "gulp-zip";
import * as vinylPaths from "vinyl-paths";
import * as del from "del";
import { resolve } from "path";
import { MissionPaths } from "./src";
import { Preset, FolderStructureInfo} from "./src";
import { ConfigCppGenerator } from "./src/ConfigCppGenerator"

var fs = require('fs');
const ROOT_DIR = resolve('../..');
const presets: Preset[] = require('./_presets.json');


/**
 * Mission folders configuration
*/
const paths: FolderStructureInfo = {
    frameworkFolder: resolve(ROOT_DIR, 'Vindicta.Altis'),
    missionsFolder: resolve(ROOT_DIR),
    workDir: resolve(ROOT_DIR, "_build"),
    configDir: resolve(ROOT_DIR, "configs")
};

// Resolve our mission's version
console.log('Reading version...');
var strMajor = fs.readFileSync(resolve(paths.configDir, "majorVersion.hpp"), 'utf8');
var strMinor = fs.readFileSync(resolve(paths.configDir, "minorVersion.hpp"), 'utf8');
var strBuild = fs.readFileSync(resolve(paths.configDir, "buildVersion.hpp"), 'utf8'); // Damn windows is adding a new line there...
var intBuild = parseInt(strBuild, 10);
strBuild = intBuild.toString();
var strVersionUnderscores = strMajor + "_" + strMinor + "_" + strBuild;
var strVersionDots = strMajor + "." + strMinor + "." + strBuild;
console.log('Building mission version:');
console.log(strVersionDots);

// Make a file which contains description.ext briefingName entry
var strBriefingName = 'briefingName = "Vindicta ' + strMajor + "." + strMinor + "." + strBuild + '";';
fs.writeFileSync(resolve(paths.configDir, "briefingName.hpp"), strBriefingName,  'utf8');

// Store values of addon path
// I know the 4 lines of code below are a clustrfuck and make little sense... I'm a noob at this
var missionTemp = new MissionPaths(presets[0], paths, strVersionUnderscores, strVersionDots);
var missionAddonDir = missionTemp.getAddonDir();
var missionNameVersion = missionTemp.getNameVersion();
var missionBriefingName = strBriefingName;
var missionWorkDir = missionTemp.getWorkDir();

// Init config.cpp generator
var configCppGenerator = new ConfigCppGenerator(missionNameVersion);


/**
 * Create gulp tasks
 */
let taskNames: string[] = [];
let taskNamesPbo: string[] = [];
let taskNamesZip: string[] = [];

for (let preset of presets) {
    const mission = new MissionPaths(preset, paths, strVersionUnderscores, strVersionDots);
    const taskName = [preset.missionName, preset.map].join('.');

    // Call config.cpp generator
    configCppGenerator.addMission(
        mission.getNameMapVersion(),
        mission.getMap(),
        mission.getBriefingName()
    );

    taskNames.push('mission_' + taskName);

    gulp.task('mission_' + taskName, gulp.series(
        /** Copy mission framework to output dir */
        function copyFramework() {
            return gulp.src(
                [
                    mission.getFrameworkPath().concat('/**/*'),
                    '!' + mission.getFrameworkPath().concat('/**/*.sqm*')
                ])
                .pipe(gulp.dest(mission.getOutputDir()));
        },

        /** Copy mission.sqm to output dir */
        function copyMissionSQM() {
            return gulp.src(mission.getMissionSqmPath())
                .pipe(rename('mission.sqm'))
                .pipe(gulp.dest(mission.getOutputDir()));
        },

        /** Copy config files to output dir */
        function copyConfigFiles() {
            return gulp.src(mission.getMissionConfigFilePaths())
                .pipe(gulp.dest(resolve(mission.getOutputDir(), 'config')));
        },

        /** Make a copy for packing all missions into one addon **/
        function copyFrameworkAddon() {
            return gulp.src(mission.getOutputDir().concat('/**/*'))
                .pipe(gulp.dest(mission.getOutputAddonDir()));
        }
    ));

    /**
     * Pack PBOs
     */
    taskNamesPbo.push('pack_' + taskName);

    gulp.task('pack_' + taskName, () => {
        return gulp.src(mission.getOutputDir() + '/**/*')
            .pipe(gulpPbo({
                fileName: (mission.getNameMapVersionMap() + '.pbo').toLowerCase(),
                progress: false,
                verbose: false,
                // Do not compress (SLOW and avoid signing)
                compress: false,
            }))
            .pipe(gulp.dest(mission.getWorkDir() + '/pbo'));
    });

    /**
     * Create ZIP files
     */
    taskNamesZip.push('zip_' + taskName);

    gulp.task('zip_' + taskName, () => {
        return gulp
            .src([
                resolve(ROOT_DIR, 'README.md')
            ], {
                base: ROOT_DIR // Change base dir to have correct relative paths in ZIP
            })
            .pipe(gulp.src(
                    resolve(mission.getWorkDir(), 'pbo', mission.getNameMapVersionMap() + '.pbo'), 
                    {
                        base: resolve(mission.getWorkDir(), 'pbo') // Change base dir to have correct relative paths in ZIP
                    }))
            .pipe(gulpZip(mission.getNameMapVersionMap() + '.zip'))
            .pipe(gulp.dest(mission.getWorkDir()))
    });
}

// Add task to make a pbo of all missions as single pbo
taskNamesPbo.push('pack_missions_to_addon');

gulp.task('pack_missions_to_addon', () => {
    // Write config.cpp
    fs.writeFileSync(resolve(missionAddonDir, 'config.cpp'), configCppGenerator.getOutput(),  'utf8');

    // Write proprefix
    // No use for it since the gulp-armapbo does not care about it
    //fs.writeFileSync(resolve(missionAddonDir, '$PBOPREFIX$'), 'z\\vindicta\\addons\\missions',  'utf8');

    return gulp.src(missionAddonDir + '/**/*')
        .pipe(gulpPbo({
            // Addon pbo must be lowercase, or linux admins will to hate us
            // !!! Must match to the prefix in MPMissions/..../directory !!!
            fileName: (missionNameVersion.toLowerCase() + '.pbo').toLowerCase(),
            progress: false,
            verbose: false,
            // Do not compress (SLOW)
            compress: true ? [] : [
                '**/*.sqf',
                'mission.sqm',
                'description.ext'
            ]
        }))
        .pipe(gulp.dest(paths.workDir + '/pbo'));
});

// Main tasks
gulp.task('clean', () => {
    return gulp.src(paths.workDir, { allowEmpty: true })
        .pipe(vinylPaths(function (path: string) {
            return del(path,  {force: true});
        }));
});

gulp.task('build', gulp.series(taskNames));

gulp.task('pbo', gulp.series(taskNamesPbo));

gulp.task('zip', gulp.series(taskNamesZip));

gulp.task('default',
    gulp.series(
        gulp.task('clean'),
        gulp.task('build'),
        gulp.task('pbo'),
        //gulp.task('zip'),
    )
);
